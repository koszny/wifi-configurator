var HtmlWebpackPlugin = require('html-webpack-plugin');
var ScriptExtHtmlWebpackPlugin = require('script-ext-html-webpack-plugin');
var webpack = require('webpack');

module.exports = {
    entry: './src/index.js',
    module: {
        loaders: [
            {test: /\.css/, loader: "style-loader!css-loader"},
            {test: /\.png/, loader: "url-loader"},
            {test: /\.html/,   loader: 'html-loader'}
        ]
    },
    output: {
        path: '../dist/webpage',
        filename: 'bundle.js'
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'pick Wifi to connect to',         
            inject: 'body',
            filename: 'index.html',
            template: './src/template.html'
        }),
        new ScriptExtHtmlWebpackPlugin({
			inline: ['bundle.js']
		}),
		new webpack.optimize.UglifyJsPlugin({
			compress: {
				warnings: false
			}
		})
    ]
};
