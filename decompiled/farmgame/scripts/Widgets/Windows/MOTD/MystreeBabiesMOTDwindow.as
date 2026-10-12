package Widgets.Windows.MOTD
{
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class MystreeBabiesMOTDwindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_counterMC:MovieClip;
      
      public function MystreeBabiesMOTDwindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var buildingNames:Array = null;
         var buildingObjects:Array = null;
         super.onLoadComplete(event);
         if(this.m_counterMC == null)
         {
            this.m_counterMC = m_window.mainWindow;
            if(ObjectUtil.pathExists(this.m_counterMC,["accept_bt","text_tf"]))
            {
               buildingNames = ["animal_breeding_nursery_finished","animal_breeding_nursery"];
               buildingObjects = Global.world.getObjectsByNames(buildingNames);
               if(buildingObjects.length == 0)
               {
                  addWidget(new ZwTextField(this.m_counterMC.accept_bt.text_tf,ZLocUtils.t("Dialogs","MOTD_MYSTREE_BABIES_REV1_buttontext_buy")));
               }
               else
               {
                  addWidget(new ZwTextField(this.m_counterMC.accept_bt.text_tf,ZLocUtils.t("Dialogs","MOTD_MYSTREE_BABIES_REV1_buttontext_continue")));
               }
            }
            if(Boolean(m_window.mainWindow.hasOwnProperty("discount_mc")) && Boolean(m_window.mainWindow.discount_mc.hasOwnProperty("timer_tf")))
            {
               m_window.mainWindow.discount_mc.timer_tf.text = ZLocUtils.t("Dialogs","MOTD_Christmas_Charity_Timer_Text");
            }
         }
      }
      
      private function onLinkClicked(event:Event) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","MOTD_MYSTREE_BABIES_REV1")),"_blank");
      }
   }
}

