Phoenix.set({
	daemon: false,
	openAtLogin: true,
});

const bindLaunch = (appName, key, modifiers) =>
	Key.on(key, modifiers, () => {
		const app = App.launch(appName);
		app.isActive() ? app.hide() : app.focus();
	});

bindLaunch('Google Chrome', 'c', ['cmd', 'shift']);
bindLaunch('Helium', 'j', ['cmd']);
bindLaunch('Hipchat', 'u', ['alt', 'shift']);
bindLaunch('Notes', 'n', ['alt', 'shift']);
bindLaunch('Slack', 'u', ['cmd']);
bindLaunch('Spotify', 'p', ['alt', 'shift']);
bindLaunch('iTerm', 't', ['cmd', 'shift']);

const maximise = key => {
	Key.on(key, ['cmd', 'ctrl'], () => {
		const win = Window.focused();
		if (win) {
			const parent = win.screen().flippedVisibleFrame();
			win.setFrame(parent);
		}
	});
};

const center = (key, point, size) => {
	Key.on(key, ['cmd', 'ctrl'], () => {
		const win = Window.focused();
		if (win) {
			const { width, height } = win.screen().flippedVisibleFrame();
			win.setFrame({
				x: width * point,
				y: height * point,
				width: width * size,
				height: height * size,
			});
		}
	});
};

maximise('=');
center('-', 0.01, 0.98);
center('0', 0.025, 0.95);
center('9', 0.05, 0.9);
center('8', 0.1, 0.8);
center('7', 0.15, 0.7);
center('6', 0.2, 0.6);
center('5', 0.25, 0.5);
center('4', 0.3, 0.4);
center('3', 0.35, 0.3);
center('2', 0.4, 0.2);
center('1', 0.45, 0.1);

const move = (key, cb) => {
	Key.on(key, ['shift', 'cmd'], () => {
		const win = Window.focused();
		if (win) {
			const { width, height } = win.screen().flippedVisibleFrame();
			const frame = cb({ width, height });
			win.setFrame(frame);
		}
	});
};

move('1', ({ width, height }) => ({
	x: 0,
	y: 0,
	width: width * 0.5,
	height,
}));
move('2', ({ width, height }) => ({
	x: width * 0.5,
	y: 0,
	width: width * 0.5,
	height,
}));
move('3', ({ width, height }) => ({
	x: 0,
	y: 0,
	width,
	height: height * 0.5,
}));
move('4', ({ width, height }) => ({
	x: 0,
	y: height * 0.5,
	width,
	height: height * 0.5,
}));
move('5', ({ width, height }) => ({
	x: 0,
	y: 0,
	width: width * 0.5,
	height: height * 0.5,
}));
move('6', ({ width, height }) => ({
	x: width * 0.5,
	y: 0,
	width: width * 0.5,
	height: height * 0.5,
}));
move('7', ({ width, height }) => ({
	x: 0,
	y: height * 0.5,
	width: width * 0.5,
	height: height * 0.5,
}));
move('8', ({ width, height }) => ({
	x: width * 0.5,
	y: height * 0.5,
	width: width * 0.5,
	height: height * 0.5,
}));
move('9', ({ width, height }) => ({
	x: 0,
	y: 0,
	width: width * (1 / 3),
	height,
}));
move('0', ({ width, height }) => ({
	x: width * (2 / 3),
	y: 0,
	width: width * (1 / 3),
	height,
}));
move('j', ({ width, height }) => ({
	x: width * 0.75,
	y: height * 0.75,
	width: width * 0.25,
	height: height * 0.25,
}));

// # Movement
// bind [:alt;cmd nudge +0 +10%
// bind ]:alt;cmd nudge +0 -10%
// bind ]:shift;cmd nudge +10% +0
// bind [:shift;cmd nudge -10% +0

// bind up:ctrl;cmd nudge +0 -10%
// bind down:ctrl;cmd nudge +0 +10%
// bind right:ctrl;cmd nudge +10% +0
// bind left:ctrl;cmd nudge -10% +0
