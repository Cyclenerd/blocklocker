module.exports = {
    runtimeCompiler: true,
    devServer: {
        proxy: {
            '^/api': {
                target: 'http://shop-back-end.local',
                ws: true,
                changeOrigin: true
            }
        }
    }
}