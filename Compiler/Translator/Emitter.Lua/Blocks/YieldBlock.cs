using Bridge.Contract;
using ICSharpCode.NRefactory.CSharp;
using ICSharpCode.NRefactory.TypeSystem;

namespace Bridge.Translator.Lua
{
    public class YieldBlock : AbstractEmitterBlock
    {
        public YieldBlock(IEmitter emitter, YieldBreakStatement yieldBreakStatement)
            : base(emitter, yieldBreakStatement)
        {
            this.Emitter = emitter;
            this.YieldBreakStatement = yieldBreakStatement;
        }

        public YieldBlock(IEmitter emitter, YieldReturnStatement yieldReturnStatement)
            : base(emitter, yieldReturnStatement)
        {
            this.Emitter = emitter;
            this.YieldReturnStatement = yieldReturnStatement;
        }

        public YieldBreakStatement YieldBreakStatement
        {
            get;
            set;
        }

        public YieldReturnStatement YieldReturnStatement
        {
            get;
            set;
        }

        protected override void DoEmit()
        {
            this.Write(LuaHelper.Root + ".yieldReturn");
            this.WriteOpenParentheses();
            this.YieldReturnStatement.Expression.AcceptVisitor(this.Emitter);
            this.WriteCloseParentheses();
            this.WriteSemiColon();
            this.WriteNewLine();

            /*
            if (this.YieldReturnStatement != null)
            {
                this.Write(LuaHelper.Root + ".yieldReturn");
                this.WriteOpenParentheses();
                this.YieldReturnStatement.Expression.AcceptVisitor(this.Emitter);
                this.WriteCloseParentheses();
                this.WriteSemiColon();
                this.WriteNewLine();
            }
            else
            {
                if (this.YieldBreakStatement.GetParent<ForStatement>() == null &&
                    this.YieldBreakStatement.GetParent<ForeachStatement>() == null &&
                    this.YieldBreakStatement.GetParent<WhileStatement>() == null &&
                    this.YieldBreakStatement.GetParent<DoWhileStatement>() == null)
                {
                    YieldBlock.EmitYieldReturn(this, this.Emitter.ReturnType);
                }
                else
                {
                    new BreakBlock(this.Emitter, this.YieldBreakStatement).Emit();
                }
            }*/
        }

        public static bool HasYield(AstNode node)
        {
            var visitor = new YieldSearchVisitor();
            node.AcceptVisitor(visitor);
            return visitor.Found;
        }

        public static void EmitYield(AbstractEmitterBlock block, IType returnType, MethodDeclaration methodDeclaration)
        {
            block.WriteReturn(true);
            block.Write(LuaHelper.Root, ".yield", returnType.Name);
            block.WriteOpenParentheses();
            block.WriteFunction();
            block.WriteOpenParentheses();
            AbstractMethodBlock.EmitMethodParameters(block, methodDeclaration.Parameters, methodDeclaration);
            block.WriteCloseParentheses();
            block.BeginFunctionBlock();
        }

        public static void EmitYieldReturn(AbstractEmitterBlock block, IType returnType, MethodDeclaration methodDeclaration)
        {
            block.EndFunctionBlock();
            block.WriteComma();
            if(returnType.TypeArguments.Count > 0) {
                block.Write(BridgeTypes.ToJsName(returnType.TypeArguments[0], block.Emitter));
            }
            else {
                block.Write("System.Object");
            }
            if(methodDeclaration.Parameters.Count > 0) {
                block.WriteComma();
                AbstractMethodBlock.EmitMethodParameters(block, methodDeclaration.Parameters, methodDeclaration);
            }
            block.WriteCloseParentheses();
            block.WriteNewLine();
        }
    }
}
