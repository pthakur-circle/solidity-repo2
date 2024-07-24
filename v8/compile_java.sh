#!/usr/bin/env sh
set -e

# Format foundry build output
echo "Formatting foundry output..."
BUILD_DIR="$(pwd)"/build

# Export abi and bytecode into *.abi and *.bin files
for file in "$BUILD_DIR"/*.sol/*.json; do
    cat $file | jq -r '.bytecode.object' | tr -d '\n' > "$BUILD_DIR"/$(basename "${file%.json}".bin)
    cat $file | jq -r '.abi' | tr -d '\n' > "$BUILD_DIR"/$(basename "${file%.json}".abi)
done

# Copied on image build step.
. /usr/local/bin/utils.sh

l2Targets="
CircleMaticBridge
"
generate "$l2Targets" "com.circle.blockchain.evm.contracts.generated.l2"

echo "Completed on $(date)."
