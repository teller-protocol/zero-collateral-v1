// JS Libraries
const withData = require('leche').withData;
const { t, sum, createInfo } = require('../utils/consts');
const { mockLenderInfo } = require('../utils/contracts');

// Mock contracts
const Mock = artifacts.require("./mock/util/Mock.sol");
const ZTokenToken = artifacts.require("./mock/token/SimpleToken.sol");

// Smart contracts
const Lenders = artifacts.require("./mock/base/LendersMock.sol");

contract('LendersZTokenMintedTest', function (accounts) {
    const tokensOwner = accounts[8];
    let instance;
    let zTokenInstance;
    let lendingPoolInstance;
    
    beforeEach('Setup for each test', async () => {
        zTokenInstance = await ZTokenToken.new({from: tokensOwner});
        lendingPoolInstance = await Mock.new();
        instance = await Lenders.new(
            zTokenInstance.address,
            lendingPoolInstance.address,
        );
    });

    withData({
        _1_0currentIntereset_1block_1minted: [createInfo(accounts[1], 0, 0, 1), 1, 1],
        _2_100currentInterest_1block_150minted: [createInfo(accounts[2], 2, 100, 400), 150, 4],
        _3_10currentInterest_0Blocks_50minted: [createInfo(accounts[3], 4, 10, 10), 50, 4],
    }, function(
        recipient,
        amount,
        plusBlockNumbers,
    ) {    
        it(t('user', 'zTokenMinted', 'Should able to update the accrued interest after minting zToken.', false), async function() {
            // Setup
            await zTokenInstance.mint(recipient.address, amount, { from: tokensOwner });
            // Mocking recipient info (accrued interest and lastaccrued block number) and current block number.
            const currentBlockNumber = await web3.eth.getBlockNumber();
            await mockLenderInfo(instance, recipient, currentBlockNumber);
            await instance.setCurrentBlockNumber(sum(currentBlockNumber, plusBlockNumbers));

            // Invocation
            const result = await instance.zTokenMinted(recipient.address, amount);

            // Assertions
            assert(result);
            const recipientLenderAccountResult = await instance.lenderAccounts(recipient.address);
            assert.equal(recipientLenderAccountResult.totalAccruedInterest.toString(), recipient.expectedAccruedInterest.toString());
        });
    });
});