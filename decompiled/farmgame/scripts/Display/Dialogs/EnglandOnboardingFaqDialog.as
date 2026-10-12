package Display.Dialogs
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class EnglandOnboardingFaqDialog extends FarmDynamicDialog implements ICellController
   {
      
      private var m_questionAnswerPairs:Array = null;
      
      public function EnglandOnboardingFaqDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var qaGroupController:BaseWidgetController = null;
         var text:BaseWidgetController = null;
         var qaGroup:Array = this.m_questionAnswerPairs[index];
         if(qaGroup != null)
         {
            if(qaGroup.length > 0)
            {
               qaGroupController = newCell.getChildController("leftQAGroup");
               text = qaGroupController.getChildController("questionText");
               text.setAttribute(TextFieldView.ATTRIBUTE_TEXT,qaGroup[0]["question"]);
               text = qaGroupController.getChildController("answerText");
               text.setAttribute(TextFieldView.ATTRIBUTE_TEXT,qaGroup[0]["answer"]);
            }
            if(qaGroup.length > 1)
            {
               qaGroupController = newCell.getChildController("rightQAGroup");
               text = qaGroupController.getChildController("questionText");
               text.setAttribute(TextFieldView.ATTRIBUTE_TEXT,qaGroup[1]["question"]);
               text = qaGroupController.getChildController("answerText");
               text.setAttribute(TextFieldView.ATTRIBUTE_TEXT,qaGroup[1]["answer"]);
            }
         }
         return newCell;
      }
      
      override public function setup() : void
      {
         super.setup();
         this.setupTitle();
         this.setupQuestionAnswerSection();
         this.setShortcutAttribute("button",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
      }
      
      private function setupTitle() : void
      {
         this.setShortcutAttribute("titleText1",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglandOnboardingFaqTitle1"));
         this.setShortcutAttribute("titleText2",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglandOnboardingFaqTitle2"));
      }
      
      private function setupQuestionAnswerSection() : void
      {
         this.createQuestionAnswerPairs();
         this.setShortcutAttribute("qaContent",CellController.ATTRIBUTE_CREATE,this);
         this.setShortcutAttribute("qaContent",CellController.ATTRIBUTE_CELL_COUNT,this.m_questionAnswerPairs.length);
      }
      
      private function createQuestionAnswerPairs() : void
      {
         this.m_questionAnswerPairs = [];
         var questionAnswerPair:Object = null;
         var textBundleName:String = "Dialogs";
         var questionResourceName:String = "EnglandOnboardingQuestion";
         var answerResourceName:String = "EnglandOnboardingAnswer";
         var qaGroup:Array = null;
         var qaIndex:int = 1;
         while(ZLocUtils.hasString(textBundleName,questionResourceName + "_" + qaIndex.toString()) && ZLocUtils.hasString(textBundleName,answerResourceName + "_" + qaIndex.toString()))
         {
            if(qaGroup == null)
            {
               qaGroup = [];
            }
            questionAnswerPair = {};
            questionAnswerPair["question"] = ZLocUtils.t(textBundleName,questionResourceName + "_" + qaIndex.toString());
            questionAnswerPair["answer"] = ZLocUtils.t(textBundleName,answerResourceName + "_" + qaIndex.toString());
            qaGroup.push(questionAnswerPair);
            if(qaGroup.length == 2)
            {
               this.m_questionAnswerPairs.push(qaGroup);
               qaGroup = null;
            }
            qaIndex++;
         }
         if(qaGroup != null)
         {
            this.m_questionAnswerPairs.push(qaGroup);
         }
      }
   }
}

