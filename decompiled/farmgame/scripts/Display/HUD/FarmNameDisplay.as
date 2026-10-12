package Display.HUD
{
   import Classes.util.ZLocUtils;
   import Display.FarmGameSprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class FarmNameDisplay extends FarmGameSprite
   {
      
      private static const X_POSITION:int = 524;
      
      private static const Y_POSITION:int = 7;
      
      protected var m_farmName:String;
      
      protected var m_farmNameTextField:TextField;
      
      public function FarmNameDisplay()
      {
         super();
         this.x = X_POSITION;
         this.y = Y_POSITION;
         this.trackClicks(false);
      }
      
      public function release() : void
      {
         hideToolTip();
      }
      
      protected function set farmName(farmName:String) : void
      {
         this.m_farmName = farmName;
         if(this.m_farmNameTextField)
         {
            this.m_farmNameTextField.autoSize = TextFieldAutoSize.CENTER;
            this.m_farmNameTextField.defaultTextFormat = HUDFonts.TitleText;
            this.m_farmNameTextField.setTextFormat(HUDFonts.TitleText);
            this.m_farmNameTextField.embedFonts = true;
            this.m_farmNameTextField.text = this.m_farmName;
         }
      }
      
      public function setFarmNameFromPlayerName(playerName:String) : void
      {
         this.farmName = ZLocUtils.t("FarmGame","FarmName",{"user":ZLocUtils.tn(playerName)});
      }
      
      public function setFarmNameByLocation() : void
      {
         var currentWorldType:String = Global.worldManager.currentWorldType;
         this.farmName = ZLocUtils.t("FarmGame","FarmName_" + currentWorldType);
      }
   }
}

