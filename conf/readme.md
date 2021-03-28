
# 配置

- core.autocrlf

    - true
        
        提交时转换为LF，检出时转换为CRLF

    - input
    
        提交时转换为LF，检出时不转换

    - false
    
        提交检出均不转换

- core.safecrlf

    - true
    
        拒绝提交包含混合换行符的文件

    - false
    
        允许提交包含混合换行符的文件

    - warn
    
        提交包含混合换行符的文件时给出警告
