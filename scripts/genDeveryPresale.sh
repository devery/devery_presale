#!/bin/sh

geth attach << EOF | grep "JSONSUMMARY:" | sed "s/JSONSUMMARY: //" > tmp.json
loadScript("deveryPresale.js");
// loadScript("whiteList.js");

function generateSummaryJSON() {
  console.log("JSONSUMMARY: {");
  var whiteList = null
  // if (whiteListAddress != null && whiteListAbi != null) {
  //   whiteList = eth.contract(whiteListAbi).at(whiteListAddress);
  // }
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    var blockNumber = eth.blockNumber;
    var timestamp = eth.getBlock(blockNumber).timestamp;
    console.log("JSONSUMMARY:   \"blockNumber\": " + blockNumber + ",");
    console.log("JSONSUMMARY:   \"blockTimestamp\": " + timestamp + ",");
    console.log("JSONSUMMARY:   \"blockTimestampString\": \"" + new Date(timestamp * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractAddress\": \"" + crowdsaleContractAddress + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractOwnerAddress\": \"" + contract.owner() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractNewOwnerAddress\": \"" + contract.newOwner() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleWalletAddress\": \"" + contract.wallet() + "\",");
    console.log("JSONSUMMARY:   \"tokenSymbol\": \"" + contract.symbol() + "\",");
    console.log("JSONSUMMARY:   \"tokenName\": \"" + contract.name() + "\",");
    console.log("JSONSUMMARY:   \"tokenDecimals\": \"" + contract.decimals() + "\",");
    console.log("JSONSUMMARY:   \"tokenTotalSupply\": \"" + contract.totalSupply() + "\",");
    console.log("JSONSUMMARY:   \"tokenTransferable\": \"" + contract.transferable() + "\",");
    console.log("JSONSUMMARY:   \"tokenMintable\": \"" + contract.mintable() + "\",");
    var startDate = contract.START_DATE();
    console.log("JSONSUMMARY:   \"crowdsaleStart\": " + startDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleStartString\": \"" + new Date(startDate * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleStartUTCString\": \"" + new Date(startDate * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleClosed\": \"" + contract.closed() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleEthMinContribution\": " + contract.ethMinContribution() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleTestContribution\": " + contract.TEST_CONTRIBUTION().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleUsdCap\": " + contract.usdCap() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleUsdPerKEther\": " + contract.usdPerKEther() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleContributedEth\": " + contract.contributedEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleContributedUsd\": " + contract.contributedUsd() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleWhiteListAddress\": \"" + contract.whitelist() + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePICOPSCertifier\": \"" + contract.picopsCertifier() + "\"");
    

/*
    console.log("JSONSUMMARY:   \"tokenContractAddress\": \"" + contract.bttsToken() + "\",");
    console.log("JSONSUMMARY:   \"tokenContractDecimals\": " + contract.TOKEN_DECIMALS() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleTeamWalletAddress\": \"" + contract.teamWallet() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleTeamPercent\": " + contract.TEAM_PERCENT_GZE() + ",");
    console.log("JSONSUMMARY:   \"bonusListContractAddress\": \"" + contract.bonusList() + "\",");
    console.log("JSONSUMMARY:   \"tier1Bonus\": " + contract.TIER1_BONUS() + ",");
    console.log("JSONSUMMARY:   \"tier2Bonus\": " + contract.TIER2_BONUS() + ",");
    console.log("JSONSUMMARY:   \"tier3Bonus\": " + contract.TIER3_BONUS() + ",");
    var startDate = contract.START_DATE();
    var endDate = contract.endDate();
    console.log("JSONSUMMARY:   \"crowdsaleStart\": " + startDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleStartString\": \"" + new Date(startDate * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleEnd\": " + endDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleEndString\": \"" + new Date(endDate * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"usdPerEther\": " + contract.usdPerKEther().shift(-3) + ",");
    console.log("JSONSUMMARY:   \"usdPerGze\": " + contract.USD_CENT_PER_GZE().shift(-2) + ",");
    console.log("JSONSUMMARY:   \"gzePerEth\": " + contract.gzePerEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"capInUsd\": " + contract.CAP_USD() + ",");
    console.log("JSONSUMMARY:   \"capInEth\": " + contract.capEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"minimumContributionEth\": " + contract.MIN_CONTRIBUTION_ETH().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"contributedEth\": " + contract.contributedEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"contributedUsd\": " + contract.contributedUsd() + ",");
    console.log("JSONSUMMARY:   \"generatedGze\": " + contract.generatedGze().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"lockedAccountThresholdUsd\": " + contract.lockedAccountThresholdUsd() + ",");
    console.log("JSONSUMMARY:   \"lockedAccountThresholdEth\": " + contract.lockedAccountThresholdEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"precommitmentAdjusted\": " + contract.precommitmentAdjusted() + ",");
    console.log("JSONSUMMARY:   \"finalised\": " + contract.finalised() + ",");
    var separator = "";
    var fromBlock = 4708298;
    var contributedEvents = contract.Contributed({}, { fromBlock: fromBlock, toBlock: "latest" }).get();
    console.log("JSONSUMMARY:   \"numberOfContributions\": " + contributedEvents.length + ",");
    console.log("JSONSUMMARY:   \"contributions\": [");
    for (var i = 0; i < contributedEvents.length; i++) {
      var e = contributedEvents[contributedEvents.length - 1 - i];
      var separator;
      if (i == contributedEvents.length - 1) {
        separator = "";
      } else {
        separator = ",";
      }
      var ts = eth.getBlock(e.blockNumber).timestamp;
      console.log("JSONSUMMARY:     {");
      console.log("JSONSUMMARY:       \"address\": \"" + e.args.addr + "\",");
      var tier = bonusList != null ? bonusList.bonusList(e.args.addr) : 0;
      console.log("JSONSUMMARY:       \"tier\": " + tier + ",");
      var bonusPercent = contract.getBonusPercent(e.args.addr);
      console.log("JSONSUMMARY:       \"bonusPercent\": " + bonusPercent + ",");
      console.log("JSONSUMMARY:       \"transactionHash\": \"" + e.transactionHash + "\",");
      console.log("JSONSUMMARY:       \"href\": \"https://etherscan.io/tx/" + e.transactionHash + "\",");
      console.log("JSONSUMMARY:       \"blockNumber\": " + e.blockNumber + ",");
      console.log("JSONSUMMARY:       \"transactionIndex\": " + e.transactionIndex + ",");
      console.log("JSONSUMMARY:       \"timestamp\": " + ts + ",");
      console.log("JSONSUMMARY:       \"timestampString\": \"" + new Date(ts * 1000).toUTCString() + "\",");
      console.log("JSONSUMMARY:       \"ethAmount\": " + e.args.ethAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"ethRefund\": " + e.args.ethRefund.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"accountTotalEthAmount\": " + e.args.accountEthAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"usdAmount\": " + e.args.usdAmount + ",");
      console.log("JSONSUMMARY:       \"gzeAmount\": " + e.args.gzeAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"contributedEth\": " + e.args.contributedEth.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"contributedUsd\": " + e.args.contributedUsd + ",");
      console.log("JSONSUMMARY:       \"generatedGze\": " + e.args.generatedGze.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"accountLocked\": " + e.args.lockAccount + "");
      console.log("JSONSUMMARY:     }" + separator);
    }
    console.log("JSONSUMMARY:   ]");
    */
  }
  console.log("JSONSUMMARY: }");
}

generateSummaryJSON();
EOF

mv tmp.json DeveryPresaleSummary.json
