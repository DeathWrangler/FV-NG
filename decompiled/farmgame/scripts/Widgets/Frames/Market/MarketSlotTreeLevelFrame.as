package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class MarketSlotTreeLevelFrame extends ZwFrame
   {
      
      private var m_treeLevelTextField:ZwTextField;
      
      public function MarketSlotTreeLevelFrame(element:MovieClip)
      {
         super(element);
         this.m_treeLevelTextField = addWidget(new ZwTextField(m_element.trlvl_tf)) as ZwTextField;
      }
      
      public function set treeLevel(value:int) : void
      {
         this.m_treeLevelTextField.text = ZLocUtils.t("Dialogs","TreeLevel",{"quantity":value});
      }
      
      override public function release() : void
      {
         this.m_treeLevelTextField = null;
         super.release();
      }
   }
}

