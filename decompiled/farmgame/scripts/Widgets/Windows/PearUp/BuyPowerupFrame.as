package Widgets.Windows.PearUp
{
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   
   internal class BuyPowerupFrame
   {
      
      public var frame:ZwFrame = null;
      
      public var m_buyButton:FarmAnimatedCashButton = null;
      
      public var m_useButton:FarmAnimatedButton = null;
      
      public var m_titleTextField:ZwTextField = null;
      
      public var m_amountTextField:ZwTextField = null;
      
      public var m_headerTextField:ZwTextField = null;
      
      public function BuyPowerupFrame()
      {
         super();
      }
      
      public function showUseButton() : void
      {
         if(this.m_useButton)
         {
            this.m_useButton.visible = true;
            this.m_useButton.enabled = true;
            this.m_useButton.applyGrayOut = false;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = false;
            this.m_buyButton.enabled = false;
            this.m_buyButton.applyGrayOut = true;
         }
      }
      
      public function showBuyButton() : void
      {
         if(this.m_useButton)
         {
            this.m_useButton.visible = false;
            this.m_useButton.enabled = false;
            this.m_useButton.applyGrayOut = true;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = true;
            this.m_buyButton.enabled = true;
            this.m_buyButton.applyGrayOut = false;
         }
      }
      
      public function disableButtons() : void
      {
         if(this.m_useButton)
         {
            this.m_useButton.enabled = false;
            this.m_useButton.applyGrayOut = true;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.enabled = false;
            this.m_buyButton.applyGrayOut = true;
         }
      }
   }
}

