-include .env

# the :; is for writing the command on the same line (if not just hit enter and tab in the next line)
build:; forge build

generate-input-data:; forge script script/GenerateInput.s.sol:GenerateInput

generate-merkle-data:; forge script script/MakeMerkle.s.sol:MakeMerkle