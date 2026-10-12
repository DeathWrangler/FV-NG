package Display.HUD
{
   import Classes.EmbeddedArt;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import flash.display.DisplayObject;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class BasicNameDisplay extends FarmNameDisplay
   {
      
      private var m_farmNameFrame:DisplayObject;
      
      public function BasicNameDisplay()
      {
         super();
         this.farmNameCreate();
      }
      
      private function farmNameCreate() : void
      {
         this.m_farmNameFrame = new EmbeddedArt.hud_farmName_frame();
         this.addChild(this.m_farmNameFrame);
         m_farmNameTextField = new TextField();
         m_farmNameTextField.selectable = false;
         m_farmNameTextField.autoSize = TextFieldAutoSize.CENTER;
         m_farmNameTextField.defaultTextFormat = HUDFonts.TitleText;
         m_farmNameTextField.setTextFormat(HUDFonts.TitleText);
         m_farmNameTextField.embedFonts = true;
         m_farmNameTextField.x = this.m_farmNameFrame.x + this.m_farmNameFrame.width / 2;
         m_farmNameTextField.y = this.m_farmNameFrame.y + 2;
         m_farmNameTextField.mouseWheelEnabled = false;
         Utilities.toggleInputOnlySelf(m_farmNameTextField,false);
         this.addChild(m_farmNameTextField);
      }
      
      override protected function set farmName(farmName:String) : void
      {
         var toolTip:String = null;
         super.farmName = farmName;
         if(Global.worldManager.isVisiting() == true)
         {
            toolTip = ZLocUtils.t("FarmGame","FarmNameOther_ToolTip",{"farm":ZLocUtils.tn(m_farmName)});
         }
         else
         {
            toolTip = ZLocUtils.t("FarmGame","FarmNameSelf_ToolTip");
         }
         this.toolTip = toolTip;
      }
   }
}

