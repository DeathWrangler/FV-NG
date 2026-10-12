package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class MarketSlotInventoryFrame extends ZwFrame
   {
      
      private static const TOP_BUTTON_POSITION_Y:int = 3;
      
      private static const BOTTOM_BUTTON_POSITION_Y:int = 23;
      
      private var m_countTextField:ZwTextField;
      
      private var m_getButton:FarmAnimatedTextButton;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      public function MarketSlotInventoryFrame(element:MovieClip, callback:Function)
      {
         super(element);
         this.m_countTextField = addWidget(new ZwTextField(m_element.counter_tf),false) as ZwTextField;
         this.m_getButton = addWidget(new FarmAnimatedTextButton(m_element.get_bt,ZLocUtils.t("Dialogs","MarketCardGetButton"),callback)) as FarmAnimatedTextButton;
         this.m_useButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","MarketCardUseButton"),callback),false) as FarmAnimatedTextButton;
      }
      
      public function update(count:int, isGetButtonVisible:Boolean = true, isUseButtonVisible:Boolean = false) : void
      {
         var seedCountText:String = null;
         if(count > 0)
         {
            seedCountText = "";
            if(count > 10000)
            {
               seedCountText = ZLocUtils.t("Dialogs","Max");
            }
            else if(count >= 1000)
            {
               seedCountText = ">" + Math.floor(count / 1000) + "k";
            }
            else
            {
               seedCountText = "x" + Utilities.formatNumber(count);
            }
            this.m_countTextField.text = seedCountText;
            this.m_countTextField.visible = true;
            this.m_useButton.visible = true;
            this.m_getButton.y = TOP_BUTTON_POSITION_Y;
         }
         else if(isUseButtonVisible)
         {
            this.m_countTextField.visible = false;
            this.m_useButton.y = BOTTOM_BUTTON_POSITION_Y;
            this.m_useButton.visible = true;
            this.m_getButton.y = TOP_BUTTON_POSITION_Y;
            this.m_getButton.visible = false;
         }
         else
         {
            this.m_countTextField.visible = false;
            this.m_useButton.visible = false;
            this.m_getButton.y = BOTTOM_BUTTON_POSITION_Y;
         }
         this.m_getButton.visible = isGetButtonVisible;
      }
      
      public function get getButton() : FarmAnimatedTextButton
      {
         return this.m_getButton;
      }
      
      public function get useButton() : FarmAnimatedTextButton
      {
         return this.m_useButton;
      }
      
      override public function release() : void
      {
         this.m_countTextField = null;
         this.m_getButton = null;
         this.m_useButton = null;
         super.release();
      }
   }
}

