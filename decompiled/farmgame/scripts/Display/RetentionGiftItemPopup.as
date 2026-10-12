package Display
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class RetentionGiftItemPopup extends FarmWindow
   {
      
      protected var m_dialogKey:String;
      
      protected var m_dialogAccept:String;
      
      protected var m_dialogTitle:String;
      
      protected var m_itemNames:Array;
      
      protected var m_counterName:String;
      
      public function RetentionGiftItemPopup(dialogURL:String, itemNames:Array, counterName:String, dialogAccept:String = "RetentionAccept", dialogTitle:String = "RetentionTitle")
      {
         super(dialogURL);
         this.m_dialogAccept = dialogAccept;
         this.m_dialogTitle = dialogTitle;
         this.m_itemNames = itemNames;
         this.m_counterName = counterName;
         this.m_dialogKey = "Retention_" + this.m_itemNames[0];
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwBaseWidget(m_window.container_mc));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs",this.m_dialogAccept),this.onAccept));
         addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_dialogTitle)));
         addWidget(new FarmTextField(m_window.popupBox_tf,ZLocUtils.t("Dialogs",this.m_dialogKey)));
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         this.close();
         if(this.m_itemNames[0])
         {
            Global.world.enterForcePlaceMode(this.m_itemNames[0]);
            StatsManager.count(this.m_counterName,"dialog","place",this.m_itemNames[0]);
         }
      }
   }
}

