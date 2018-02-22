module.exports = {
	extends: 'airbnb',
	env: {
		browser: true,
		mocha: true,
		node: true,
	},
	rules: {
		'comma-dangle': 0,
		'no-tabs': 0,
		'react/jsx-filename-extension': 0,
		'react/jsx-indent': 0,
		'react/jsx-indent-props': 0,
		indent: [2, 'tab'],
	},
};
