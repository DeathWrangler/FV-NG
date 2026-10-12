package Widgets.Windows.MOTD
{
   import Classes.MysteryCrateBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class MysteryCrateMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function MysteryCrateMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String = null;
         var partName:String = null;
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),onAccept));
         addWidget(new ZwButton(m_window.mainWindow.close_bt,this.onClose));
         if(m_window.mainWindow.title_tf)
         {
            titleText = ZLocUtils.t_pk(m_currentMOTD["title"]);
            if(titleText != "")
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,titleText));
            }
         }
         if(m_window.mainWindow.body_tf)
         {
            partName = "";
            switch(Global.flashHotParams["MYSTERY_CRATE_PART_TYPE"])
            {
               case MysteryCrateBuilding.SNIPS_PART_NAME:
                  partName = MysteryCrateBuilding.PART_TYPE_SNIPS;
                  break;
               case MysteryCrateBuilding.SCISSORS_PART_NAME:
               default:
                  partName = MysteryCrateBuilding.PART_TYPE_SCISSORS;
            }
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","mysterycrate_MOTD_Text",{"part":partName})));
         }
         m_window.mainWindow.back_mc.visible = true;
         m_window.mainWindow.back_mc.gotoAndPlay(2);
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_cancelCallback !== null)
         {
            m_cancelCallback.call();
         }
         close();
      }
   }
}

