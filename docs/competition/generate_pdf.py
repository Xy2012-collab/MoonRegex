"""Generate MoonRegex proposal PDF."""
from fpdf import FPDF
import os, shutil

script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")
if not os.path.exists(local_font):
    for fp in ["C:/Windows/Fonts/msyh.ttc","C:/Windows/Fonts/msyhbd.ttc","C:/Windows/Fonts/simsun.ttc","C:/Windows/Fonts/simhei.ttf"]:
        if os.path.exists(fp): shutil.copy(fp, local_font); break
if not os.path.exists(local_font): print("ERROR: No Chinese font!"); exit(1)

PRIMARY = (40, 90, 60)
LIGHT = (242, 250, 245)

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)
    def header(self): pass
    def footer(self): pass
    def banner(self, title, sub):
        self.set_fill_color(*PRIMARY); self.set_text_color(255,255,255)
        self.rect(self.l_margin,self.get_y(),self.w-self.l_margin-self.r_margin,18,style="F")
        self.set_font("F","B",15); self.set_y(self.get_y()+2)
        self.cell(0,7,title,align="C",new_x="LMARGIN",new_y="NEXT")
        self.set_font("F","",7.5); self.set_y(self.get_y()-1)
        self.cell(0,5,sub,align="C",new_x="LMARGIN",new_y="NEXT")
        self.set_y(self.get_y()+20)
    def sec(self, text):
        self.ln(2); self.set_font("F","B",10.5); self.set_text_color(*PRIMARY)
        self.set_fill_color(*PRIMARY); self.rect(self.l_margin,self.get_y()+1,2.5,5,style="F")
        self.set_x(self.l_margin+5); self.cell(0,6,text,new_x="LMARGIN",new_y="NEXT"); self.ln(2)
    def info(self, label, value):
        self.set_font("F","B",7.5); self.set_text_color(*PRIMARY)
        self.cell(26,4.5,"  "+label)
        self.set_font("F","",7.5); self.set_text_color(35,45,38)
        self.cell(0,4.5,value,new_x="LMARGIN",new_y="NEXT")
    def body(self, text):
        self.set_font("F","",7); self.set_text_color(70,80,72)
        self.set_x(self.l_margin+5)
        self.multi_cell(self.w-self.l_margin-self.r_margin-5,3.6,text,align="L")
    def t_header(self, cells, widths):
        self.set_fill_color(*PRIMARY); self.set_text_color(255,255,255); self.set_font("F","B",7); h=5
        self.set_x(self.l_margin+5)
        for cell, w in zip(cells, widths):
            self.rect(self.get_x(),self.get_y(),w,h,style="F"); self.cell(w,h," "+cell)
        self.ln(h)
    def t_row(self, cells, widths, bold=False):
        self.set_fill_color(*LIGHT) if bold else self.set_fill_color(255,255,255)
        self.set_font("F","B",7) if bold else self.set_font("F","",7)
        self.set_text_color(35,45,38); h=4.8
        self.set_x(self.l_margin+5)
        for i,(cell,w) in enumerate(zip(cells,widths)):
            self.rect(self.get_x(),self.get_y(),w,h,style="DF")
            if i==0: self.set_fill_color(*PRIMARY); self.rect(self.get_x(),self.get_y(),1.5,h,style="F")
            self.set_fill_color(*LIGHT) if bold else self.set_fill_color(255,255,255)
            self.cell(w,h,"  "+cell)
        self.ln(h)

pdf = PDF(); pdf.set_auto_page_break(auto=False); pdf.add_page()
pdf.banner("MoonRegex 项目申报书", "2026 MoonBit 国产开源生态竞赛 · 个人赛")

pdf.sec("基本信息")
pdf.info("项目名称", "MoonRegex：纯 MoonBit 正则表达式引擎")
pdf.info("GitHub", "https://github.com/Xy2012-collab/MoonRegex")
pdf.info("GitLink", "https://gitlink.org.cn/X1119/MoonRegex")
pdf.info("项目方向", "MoonBit 基础库 / 文本处理")
pdf.info("类型/许可证", "原创项目  /  Apache-2.0")

pdf.sec("项目简介")
pdf.body("MoonRegex 是纯 MoonBit 实现的正则表达式引擎，基于 AST 编译+递归回溯匹配。支持完整正则语法（.*+?|()[] [a-z] \\d\\w\\s {n,m}），提供 match/find/replace/split/count 共7种 API，92个测试通过，零外部依赖。")

pdf.sec("核心功能")
pdf.t_header(["类别", "数量", "典型项"], [28,14,124])
for row in [
    ("基础语法", "6", "字面量 / . / * / + / ? / | / ()"),
    ("字符类", "4", "[] / [^] / [a-z] / [0-9] / [A-Z]"),
    ("转义序列", "6", "\\d / \\D / \\w / \\W / \\s / \\S"),
    ("计数重复", "3", "{n} / {n,} / {n,m}"),
    ("锚点", "2", "^ 开始 / $ 结束"),
    ("API方法", "7", "match / find / find_all / replace / split / count / match_result"),
]:
    pdf.t_row(row, [28,14,124])
pdf.ln(1)

pdf.sec("差异化定位")
pdf.body("MoonRegex 是 MoonBit 生态中的正则表达式引擎。与字符串硬编码搜索相比，MoonRegex 提供声明式的模式匹配能力，92个测试覆盖完整语法。采用 AST 编译架构，解析与匹配分离，方便后续扩展（如 DFA 优化、Non-backtracking 匹配）。")
pdf.t_header(["维度", "MoonRegex", "MoonBit 生态"], [36,65,65])
for row in [
    ("正则语法", "支持25+种语法特性", "无可对标项目"),
    ("API", "7种方法（match/find/replace/split/count）", "无可对标项目"),
    ("依赖", "零外部依赖，纯 MoonBit", "—"),
]:
    pdf.t_row(row, [36,65,65])
pdf.ln(1)

pdf.sec("项目规模")
pdf.t_header(["类别", "行数", "说明"], [48,24,90])
for row in [
    ("正则引擎", "600", "parser / AST / matcher — 核心逻辑"),
    ("测试", "570", "92个测试全部通过"),
    ("文档+CI", "251", "README / CI / 申报材料"),
    ("合计", "1,421", "9次有效提交"),
]:
    pdf.t_row(row, [48,24,90], bold=(row[0]=="合计"))
pdf.ln(1)

pdf.sec("适用场景")
pdf.body("输入验证（邮箱/手机号/日期格式） · 日志解析与提取 · 文本搜索替换 · 配置文件格式验证 · 数据清洗与 ETL · MoonBit 生态文本处理基础设施")

output_path = os.path.join(script_dir, "MoonRegex项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
