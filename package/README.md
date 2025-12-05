# 打包脚本使用说明

本文件夹包含用于压缩和解压缩 Vivado 项目的脚本。

## 文件说明

- `compress.sh` - Mac 系统压缩脚本
- `decompress.bat` - Windows 系统解压缩脚本

---

## Mac 系统 - 压缩文件

### 脚本名称
`compress.sh`

### 使用方法

```bash
./compress.sh <源文件/文件夹路径> [输出文件名]
```

### 参数说明
- `源文件/文件夹路径`（必需）：要压缩的文件或文件夹路径
- `输出文件名`（可选）：压缩后的文件名，如不指定则自动生成带时间戳的文件名

### 使用示例

1. **压缩整个项目文件夹**（自动命名）：
```bash
./compress.sh Vivado_Learning
# 输出: Vivado_Learning_20251024_153045.zip
```

2. **压缩并指定输出文件名**：
```bash
./compress.sh Vivado_Learning my_vivado_project.zip
# 输出: my_vivado_project.zip
```

3. **压缩单个文件**：
```bash
./compress.sh ../Vivado_Learning/user/src/new/led_marquee.v
# 输出: led_marquee_20251024_153045.zip
```

### 特性
- ✅ 自动排除 .DS_Store、.git、node_modules 等无关文件
- ✅ 使用最大压缩率（-9）
- ✅ 显示压缩进度和文件大小
- ✅ 彩色输出提示

---

## Windows 系统 - 解压缩文件

### 脚本名称
`decompress.bat`

### 使用方法

```cmd
decompress.bat <压缩文件路径> [目标文件夹]
```

### 参数说明
- `压缩文件路径`（必需）：要解压的 .zip 文件路径
- `目标文件夹`（可选）：解压到的目标文件夹，如不指定则使用压缩文件名

### 使用示例

1. **解压到默认文件夹**（使用压缩文件名）：
```cmd
decompress.bat project.zip
REM 解压到: project\
```

2. **解压到指定文件夹**：
```cmd
decompress.bat Vivado_Learning_20251024_153045.zip Vivado_Restored
REM 解压到: Vivado_Restored\
```

3. **解压带路径的文件**：
```cmd
decompress.bat C:\Downloads\project.zip D:\Projects\MyProject
REM 解压到: D:\Projects\MyProject\
```

### 兼容性
- ✅ Windows 7 及以上（使用 PowerShell）
- ✅ Windows 10 1803 及以上（支持 tar 命令备选方案）
- ✅ 自动检测可用的解压工具
- ✅ 显示解压后的文件数量

---

## 完整工作流程示例

### 在 Mac 上压缩项目：
```bash
cd /Users/lijunheng/Documents/Vivado/Vivado/package
./compress.sh ../Vivado_Learning vivado_project.zip
```

### 将 zip 文件传输到 Windows

可以通过以下方式传输：
- U盘/移动硬盘
- 网络共享
- 云存储（OneDrive、Google Drive 等）
- 邮件附件

### 在 Windows 上解压项目：
```cmd
cd C:\path\to\package
decompress.bat vivado_project.zip Vivado_Learning
```

---

## 注意事项

1. **Mac 脚本权限**：首次使用前需要添加执行权限
   ```bash
   chmod +x compress.sh
   ```

2. **Windows 路径**：如果路径包含空格，请使用引号
   ```cmd
   decompress.bat "My Project.zip" "My Folder"
   ```

3. **文件大小**：Vivado 项目可能较大，确保有足够的磁盘空间

4. **编码问题**：如果文件名包含中文，可能在不同系统间传输时出现乱码

5. **排除文件**：压缩脚本会自动排除一些临时文件和系统文件，减小压缩包大小

---

## 故障排除

### Mac 压缩问题
- **权限被拒绝**：运行 `chmod +x compress.sh`
- **找不到文件**：检查路径是否正确，使用相对路径或绝对路径

### Windows 解压问题
- **PowerShell 错误**：确保使用 Windows 7 或更高版本
- **解压失败**：检查 zip 文件是否损坏，尝试重新下载
- **路径过长**：Windows 有最大路径长度限制，尝试解压到较短的路径

---

## 技术支持

如有问题或建议，请联系项目维护者。

