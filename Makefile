all    :; dapp --use solc:0.7.4 build
clean  :; dapp clean
test   :; dapp --use solc:0.7.4 test --match test
prove  :; dapp --use solc:0.7.4 test --match prove
