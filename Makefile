config:
	stow --verbose=2 .

dry.run.config:
	stow -n --verbose=2 .


reconfig:
	stow -R --verbose=2 .

dry.run.reconfig:
	stow -Rn --verbose=2 .

clean:
	stow -D --verbose=2 .

dry.run.clean: 
	stow -Dn --verbose=2 .
