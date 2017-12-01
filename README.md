# Devery Presale Contract

## Summary

* NOTE - The DeveryPresaleWhitelist contract whitelist entries are used to verify the whitelisted addresses where the
  max amount is > 0 . The max amount value is not checked against the contributed ETH value

<br />

<hr />

## Table Of Contents

* [Requirements](#requirements)
* [Testing](#testing)
  * [Test 1 Happy Path](#test-1-happy-path)

<br />

<hr />

## Requirements

* Presale opens Dec 10 2017 12:00:00 AEDT
* Presale closes if cap reached, or when owner closes the presale
* Check deployed whitelist for `max > 0` **OR** Parity PICOPS `certified(addr) == true` before accepting funds
* Presale capped at USD 2 million
* ETH/USD rate set prior to presale open date
* Minimum contribution 20 ETH
* Sample PICOPS contract https://etherscan.io/address/0x1e2f058c43ac8965938f6e9ca286685a3e63f24e#code
* Devery Presale Whitelist https://etherscan.io/address/0x38E330C4330e743a4D82D93cdC826bAe78C6E7A6#code

<br />

<hr />

## Testing

### Test 1 Happy Path

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy the Devery whitelist contract
* [x] Whitelist a few contributing addresses
* [x] Deploy Test PICOPSCertifier contract - address 0xa44a hardcoded to return true
* [x] Deploy the presale/token contract
* [x] Set presale/token contract parameters
  * [x] Set ETH min contribution amount
  * [x] Set USD cap
  * [x] Set USD per 1,000 ETH
  * [x] Assign the whitelist
  * [x] Assign the PICOPSCertifier
* [x] Wait until start date
* [x] Contribute from whitelisted address below cap
* [x] Contribute from non-whitelisted address below cap, expecting failure
* [x] Contribute above cap, excess refunded, presale closed
* [x] Contribute after presale closed, expecting failure 

Details of the testing environment can be found in [test](test).

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Devery - Dec 02 2017. The MIT Licence.