all    :; dapp --use solc:0.7.4 build
clean  :; dapp clean
test   :; dapp --use solc:0.7.4 test --match _concrete
fuzz   :; dapp --use solc:0.7.4 test --match _fuzz
prove  :; dapp --use solc:0.7.4 test --match prove --solver cvc4
