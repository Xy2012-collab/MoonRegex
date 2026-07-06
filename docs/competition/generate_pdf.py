"""Generate MoonRegex proposal PDF — modern sidebar style."""
from fpdf import FPDF
import os, shutil

script_dir = os.path.dirname(os.path.abspath(__file__))
local_font = os.path.join(script_dir, "font.ttc")
if not os.path.exists(local_font):
    for fp in ["C:/Windows/Fonts/msyh.ttc","C:/Windows/Fonts/msyhbd.ttc","C:/Windows/Fonts/simsun.ttc","C:/Windows/Fonts/simhei.ttf"]:
        if os.path.exists(fp): shutil.copy(fp, local_font); break
if not os.path.exists(local_font): print("ERROR: No Chinese font!"); exit(1)

P = (55, 55, 65)       # dark slate
PA = (120, 80, 140)    # muted purple accent
LT = (248, 248, 252)   # light bg
DK = (35, 35, 45)      # text
MD = (100, 100, 110)   # muted text

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", fname=local_font)
        self.add_font("F", "B", fname=local_font)
    def header(self): pass
    def footer(self): pass
    def top(self, title, sub):
        # Left sidebar + title area
        self.set_fill_color(*P)
        self.rect(self.l_margin, 0, 3, 297, style="F")  # full-height left bar
        self.set_y(10)
        self.set_x(self.l_margin+10)
        self.set_font("F","B",16); self.set_text_color(*DK)
        self.cell(0,8,title,new_x="LMARGIN",new_y="NEXT")
        self.set_x(self.l_margin+10)
        self.set_font("F","",8); self.set_text_color(*MD)
        self.cell(0,5,sub,new_x="LMARGIN",new_y="NEXT")
        self.set_draw_color(*PA); self.set_line_width(0.6)
        self.line(self.l_margin+10,self.get_y()+3,self.w-self.r_margin,self.get_y()+3)
        self.set_line_width(0.2); self.set_draw_color(0,0,0)
        self.set_y(self.get_y()+6)
    def sec(self, num, text):
        self.ln(2)
        self.set_x(self.l_margin+10)
        self.set_text_color(*PA); self.set_font("F","B",9)
        self.cell(4,5,num)
        self.set_text_color(*DK); self.set_font("F","B",10)
        self.cell(0,5,text,new_x="LMARGIN",new_y="NEXT")
        self.ln(1)
    def kv(self, k, v):
        self.set_x(self.l_margin+14)
        self.set_font("F","B",7.5); self.set_text_color(*PA)
        self.cell(26,4.2,k)
        self.set_font("F","",7.5); self.set_text_color(*DK)
        self.cell(0,4.2,v,new_x="LMARGIN",new_y="NEXT")
    def p(self, text):
        self.set_x(self.l_margin+14)
        self.set_font("F","",7); self.set_text_color(*MD)
        self.multi_cell(self.w-self.l_margin-self.r_margin-14,3.6,text)
    def tbl(self, header, rows):
        self.set_x(self.l_margin+14)
        self.set_fill_color(*P); self.set_text_color(255,255,255); self.set_font("F","B",7)
        h=5; widths = [32,14,120]
        for cell,w in zip(header,widths):
            self.rect(self.get_x(),self.get_y(),w,h,style="F"); self.cell(w,h," "+cell)
        self.ln(h)
        for i,(cells) in enumerate(rows):
            self.set_x(self.l_margin+14)
            is_last = (i==len(rows)-1)
            self.set_fill_color(*LT) if is_last else self.set_fill_color(255,255,255)
            self.set_font("F","B",7) if is_last else self.set_font("F","",7)
            self.set_text_color(*DK)
            for j,(cell,w) in enumerate(zip(cells,widths)):
                self.rect(self.get_x(),self.get_y(),w,h,style="DF")
                self.cell(w,h," "+cell)
            self.ln(h-0.2)

pdf = PDF(); pdf.set_auto_page_break(auto=False); pdf.add_page()
pdf.top("MoonRegex 项目申报书", "2026 MoonBit 国产开源生态竞赛 · 个人赛")

pdf.sec("01", "基本信息")
pdf.kv("项目名称", "MoonRegex：纯 MoonBit 正则表达式引擎")
pdf.kv("GitHub", "https://github.com/Xy2012-collab/MoonRegex")
pdf.kv("GitLink", "https://gitlink.org.cn/X1119/MoonRegex")
pdf.kv("方向 / 许可证", "MoonBit 基础库 · 文本处理  /  Apache-2.0  ·  原创")

pdf.sec("02", "项目简介")
pdf.p("MoonRegex 是纯 MoonBit 实现的正则表达式引擎，基于 AST 编译 + 递归回溯匹配。支持完整正则语法（.*+?|()[] [a-z] \\d\\w\\s {n,m}），提供7种API（match/find/replace/split/count），零外部依赖。MoonBit 生态缺乏正则表达式引擎，本项目填补了这一基础工具空白。")

pdf.sec("03", "核心功能")
pdf.tbl(["类别", "数量", "具体项"], [
    ("基础语法", "6", "字面量 / . / * / + / ? / | / ()"),
    ("字符类", "4", "[] / [^] / [a-z] / [0-9] / [A-Z]"),
    ("转义", "6", "\\d / \\D / \\w / \\W / \\s / \\S"),
    ("计数重复", "3", "{n} / {n,} / {n,m}"),
    ("锚点", "2", "^ / $"),
    ("API", "7", "match / find / find_all / replace / split / count / match_result"),
])

pdf.sec("04", "差异化")
pdf.p("MoonRegex 是 MoonBit 生态中首个正则表达式引擎。对比手写字符串查找，MoonRegex 提供声明式模式匹配，92个测试覆盖完整语法。AST编译架构将解析与匹配分离，方便后续优化（如DFA编译）。")
pdf.tbl(["维度", "MoonRegex", "生态现状"], [
    ("正则语法", "25+ 种语法特性", "无可对标项目"),
    ("API", "7 种方法", "无可对标项目"),
    ("架构", "AST编译+回溯匹配", "—"),
    ("依赖", "零外部依赖", "—"),
])

pdf.sec("05", "项目规模")
pdf.tbl(["类别", "行数", "说明"], [
    ("正则引擎", "600", "parser / AST / matcher"),
    ("测试", "570", "92个测试全部通过"),
    ("文档/CI", "251", "README + CI + 申报材料"),
    ("合计", "1,421", "10次有效提交"),
])

pdf.sec("06", "适用场景")
pdf.p("输入验证 · 日志解析 · 文本搜索替换 · 配置文件验证 · 数据清洗 · MoonBit 文本处理基础设施")

output_path = os.path.join(script_dir, "MoonRegex项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
