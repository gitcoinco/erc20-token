pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';


/* this contract is deployed by a user to manage their subscriptions to Grants  */

contract Subscriptions {

	address owner;

	mapping(uint => Subscription) public subscriptions;

	struct Subscription {
			address destination;
			address recipient;
			address agent;
			uint agentRewardPct;
			uint valuePerPeriod;
			uint secondPerTimePeriod;
			uint expiration;
			uint lastWithdrawl;
			uint nextWithdrawl;
			uint grantId;
			bool active;
	}

	event newSubscription(
		address _destination,
		address _recipient,
		address _agent,
		uint _agentRewardPct,
		uint _valuePerPeriod,
		uint _secondsPerTimePeriod,
		uint _expiration,
		uint _grantId,
		bool _active
		);
	event cancelSubscription(uint _grantId);
	event changeSubscriptionStatus(uint _grantId, bool _active);
	event paymentMade(address _owner, address _recipient, address _agent, int _valuePerPeriod);



modifier periodCheck(_grantId){
	require(subscriptions[_grantId].expires > now);
	require(subscriptions[_grantId].withdrawNext <= now);
};


constructor() public {

}

/* needs modifier to ensure subscription doesn't or is already expired */
function createSubscription(
	address _destination,
	address _recipient,
	address _agent,
	uint _agentRewardPct,
	uint _valuePerPeriod,
	uint _secondsPerTimePeriod,
	uint _expiration,
	uint _grantId
	)
	public
	{

		Subscription storage sub = subscriptions[_grantId];

		sub.destination = _destination;
		sub.recipient = _recipient;
		sub.agent = _agent;
		sub.agentRewardPct = _agentRewardPct;
		sub.valuePerPeriod = _valuePerPeriod;
		sub.secondsPerTimePeriod = _secondsPerTimePeriod;
		sub.expiration = _expiration;
		sub.grantId = _grantId;
		sub.lastWithdrawl = now
		sub.nextWithdrawl = sub.lastWithdrawl + _secondsPerTimePeriod;
		sub.active = true;

		/* This exposes the subscriber to the recipient or agent draining all of the approved fund */
		/* ERC20(sub.destination).approve(sub.recipient, 999999999);
		ERC20(sub.destination).approve(sub.agent, 999999999); */
		/* Need to implement 0x assetProxy pattern */

		emit newSubscription(_destination, _recipient, _agent, _agentRewardPct, _valuePerPeriod, _secondsPerTimePeriod, _expiration, _grantId, true);
}

function revokeAgent(
	address _agent,
	uint _grantId
	)
	public
	{

		Subscription storage sub = subscriptions[_grantId];

		/* this should point to 0x assetProxy contracts */
		/* ERC20(sub.destination).approve(sub.agent, 0); */
	}



/* Should be within some sort of bounds, like, must cancel by the 15th to have applied to next month */
function cancelSubscription(
	uint _grantId
	) public {

		Subscription storage sub = subscriptions[_grantId];

		/* this should point to 0x assetProxy contracts */
		/* ERC20(sub.destination).approve(sub.recipient, 0);
		ERC20(sub.destination).approve(sub.agent, 0); */

		sub.expires = now;
		sub.active = false;

		/* need to transfer any funds that have not yet been claimed/transfared via agent */
		if (now > sub.nextWithdrawl) {

			uint unclaimedFunds = div(sub(now, sub.lastWithdrawl), sub.secondsPerTimePeriod)

			ERC20(sub.destination).transferFrom(owner, sub.recipient, unclaimedFunds);
		}


		emit cancelSubscription(_grantId);
}

/* Should be within some sort of bounds, like, must cancel by the 15th to have applied to next month */
function changeSubscriptionStatus(
	uint _grantId,
	bool _active
	) public {
		Subscription storage sub = subscriptions[_grantId];
        sub.active = _active

	/* need to transfer any funds that have not yet been claimed/transfared via agent */
	if (now > sub.nextWithdrawl) {

		uint unclaimedFunds = div(sub(now, sub.lastWithdrawl), sub.secondsPerTimePeriod)

		ERC20(sub.destination).transferFrom(owner, sub.recipient, unclaimedFunds);
	}

		emit changeSubscriptionStatus(_grantId, _active);
}

/* need to ensure that subscription is active, current blocktime is past nextWithdrawl and check how many period have past since lastWithdrawl */

/* triple check this function for vulnerabilities */
function executeSubscription(
	uint _grantId
)
periodCheck(_grantId)
public {

Subscription storage sub = subscriptions[_grantId];

/* require() that msg.sender is recipient or agent. Need to coordinate with ERC20 approve() function. */

/* this should point to 0x assetProxy contracts */


ERC20(sub.destination).transferFrom(owner, sub.recipient, sub.valuePerPeriod);

emit paymentMade(owner, sub.recipient, sub.agent, sub.valuePerPeriod);

}

function updateSubscriptionValue() public {

}

/* is there any difference between a pause function and a cancel function? maybe a cancel function does gabage collecting and uses the gas refund process.  */
function pauseSubscription() public {}


function getSubscription()
view
returns
{

}

function getUserSubscriptions() view {

}
function isValidSubscription() public {

}

}


/*
Open questions:

Do we want a pause feature on the subscriptions?
Do we assume that the agent will always be Gitcoin for these subscriptions?
Seems like having the tip funcitonality on grants page could be good if someone wants to add more value in any given month
Do we want to have an edit subscription function? Seems like maybe for value?
What hapens if someone does not claim a payment? how do we ensure they are then able to pull down the full amount, say, three periods later?
Should a payment accompany createSubsrciption?
How do we account for a users allowance running out?
How do we create an experience like a traditional contract. ex. a user signs up for a recurring payment for 24 months and can't cancel at anytime?
What are the hot wallet implications? Do subscriptions encourage users to hold prohibitively high amounts of currency on their hot wallets.

 */
