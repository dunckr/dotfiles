module.exports = {
	extends: 'airbnb',
	indent: [
		2,
		'tab',
		{
			SwitchCase: 1
		}
	],
	parserOptions: {
		ecmaVersion: 6,
		ecmaFeatures: {
			jsx: true,
			experimentalObjectRestSpread: true
		}
	},
	rules: {
		'no-console': 0,
		indent: [0, 'tab'],
		'max-len': [0, 50, 4],
		'consistent-return': 0,
		'dot-notation': 0,
		'quote-props': 0,
		'arrow-body-style': 0,
		'space-before-function-paren': 0,
		'no-unused-expressions': 0,
		'react/jsx-indent-props': 0,
		'key-spacing': 0,
		'react/no-did-update-set-state': 0,
		'react/jsx-space-before-closing': 0,
		'react/prefer-es6-class': 0,
		'jsx-quotes': [2, 'prefer-double'],
		'no-else-return': 0,
		'no-shadow': 0,
		camelcase: 0,
		radix: 0,
		'new-cap': 0,
		'no-unneeded-ternary': 0,
		'default-case': 0,
		'object-shorthand': 0,
		'no-case-declarations': 0,
		'no-use-before-define': 0,
		'no-return-assign': 0,
		'prefer-const': [
			'error',
			{
				destructuring: 'all'
			}
		],
		'prefer-rest-params': 0,
		'react/prefer-stateless-function': 0,
		'no-confusing-arrow': 0,
		'arrow-parens': ['error', 'as-needed']
	}
};
