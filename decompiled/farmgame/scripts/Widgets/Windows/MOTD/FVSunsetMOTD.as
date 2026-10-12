package Widgets.Windows.MOTD
{
   import Classes.SimpleCryptoManager;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FVSunsetMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public static const ZRUNTIME_FV_SUNSET_TEXT:String = "FV_SUNSET_TEXT";
      
      private var m_title1Tf:ZwTextField;
      
      private var m_text1Tf:ZwTextField;
      
      private var m_accept1Bt:FarmAnimatedTextButton;
      
      public function FVSunsetMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var result:String = null;
         super.postLoadComplete();
         UI.stopPopups(true);
         if(m_window.hasOwnProperty("text1_tf"))
         {
            addWidget(this.m_text1Tf = new ZwTextField(m_window["text1_tf"]));
            result = "";
            if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_FV_SUNSET_TEXT))
            {
               result = Global.flashHotParams[ZRUNTIME_FV_SUNSET_TEXT];
               result = this.decryptData(result);
            }
            this.m_text1Tf.text = result;
            this.m_text1Tf.visible = true;
         }
         if(m_window.hasOwnProperty("title1_tf"))
         {
            addWidget(this.m_title1Tf = new ZwTextField(m_window["title1_tf"]));
            this.m_title1Tf.text = "Important Announcement";
            this.m_title1Tf.visible = true;
         }
         if(m_window.hasOwnProperty("accept1_bt"))
         {
            this.m_accept1Bt = addWidget(new FarmAnimatedTextButton(m_window.accept1_bt,"Okay",this.onAccept)) as FarmAnimatedTextButton;
            this.m_accept1Bt.visible = true;
         }
         FarmStatsManager.count("MOTD","impressions","MOTD_FV_SUNSET");
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         FarmStatsManager.count("MOTD","click","MOTD_FV_SUNSET");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
         FarmStatsManager.count("MOTD","close","MOTD_FV_SUNSET");
      }
      
      private function decryptData(data:String) : String
      {
         var encryptionManager:SimpleCryptoManager = new SimpleCryptoManager();
         encryptionManager.init();
         return encryptionManager.decrypt(data);
      }
   }
}

