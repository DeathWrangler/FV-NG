package Display.Dialogs
{
   import Classes.util.ZLocUtils;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class NpcMultiSpeechBubble extends NpcSpeechBubble implements ICellController
   {
      
      private var m_speechText:Array = [];
      
      public function NpcMultiSpeechBubble(view:BaseWidgetView)
      {
         super(view);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         newCell.getChildController("bubble.bubbleText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,this.m_speechText[index]);
         return newCell;
      }
      
      override protected function getSpeechText() : void
      {
         var speechId:String = null;
         var speechSuffix:int = 1;
         while(true)
         {
            speechId = m_resourceName + "_" + speechSuffix.toString();
            if(ZLocUtils.hasString(m_bundleName,speechId) == false)
            {
               break;
            }
            this.m_speechText.push(ZLocUtils.t(m_bundleName,speechId));
            speechSuffix++;
         }
         if(this.m_speechText.length > 0)
         {
            m_singleTextBox = this.m_speechText[this.m_speechText.length - 1];
         }
      }
      
      override protected function setupSpeechText() : void
      {
         super.setupSpeechText();
         if(this.m_speechText.length > 1)
         {
            this.setShortcutAttribute("additionalBubbles",CellController.ATTRIBUTE_CREATE,this);
            this.setShortcutAttribute("additionalBubbles",CellController.ATTRIBUTE_CELL_COUNT,this.m_speechText.length - 1);
         }
      }
   }
}

