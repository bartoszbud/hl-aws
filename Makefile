.PHONY: mischief-managed

mischief-managed:
	@echo "Mischief managed!"
	find . -name ".terraform" -type d
	find . -name ".terraform.*.*" -type f
	find . -name ".terraform" -type f
