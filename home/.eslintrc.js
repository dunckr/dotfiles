module.exports = {
	extends: 'airbnb',
	env: {
		browser: true,
		jest: true,
		node: true,
	},
	rules: {
		'arrow-parens': [2, 'as-needed'],
		'comma-dangle': 0,
		'no-tabs': 0,
		'object-curly-newline': 0,
		'react/jsx-filename-extension': 0,
		'react/jsx-indent': 0,
		'react/jsx-indent-props': 0,
		'space-before-function-paren': 0,
		indent: [2, 'tab'],
	},
};
