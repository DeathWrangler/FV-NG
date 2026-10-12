package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class GenericCharityMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function GenericCharityMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),onAccept));
         if(m_window.mainWindow.headline_tf)
         {
            addWidget(new FarmTextField(m_window.mainWindow.headline_tf,Global.charityManager.motdTitle));
         }
         if(m_window.mainWindow.body_tf)
         {
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,Global.charityManager.motdBody));
         }
         if(m_window.mainWindow.close_bt)
         {
            addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose));
         }
         if(m_window.mainWindow.hasOwnProperty("link_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.mainWindow.link_mc,Global.charityManager.urlText,this.onLinkClicked));
         }
         if(m_window.mainWindow.hasOwnProperty("slot_1_mc"))
         {
            addWidget(new FarmIcon(m_window.mainWindow.slot_1_mc,Global.charityManager.logoUrl));
         }
         switch(Global.charityManager.npc)
         {
            case "anne":
               if(m_window.mainWindow.hasOwnProperty("Logo_mc"))
               {
                  m_window.mainWindow.Logo_mc.gotoAndStop(1);
               }
               break;
            case "explorerbob":
               if(m_window.mainWindow.hasOwnProperty("Logo_mc"))
               {
                  m_window.mainWindow.Logo_mc.gotoAndStop(2);
               }
               break;
            case "farmer":
               if(m_window.mainWindow.hasOwnProperty("Logo_mc"))
               {
                  m_window.mainWindow.Logo_mc.gotoAndStop(3);
               }
               break;
            case "jungleduke":
               if(m_window.mainWindow.hasOwnProperty("Logo_mc"))
               {
                  m_window.mainWindow.Logo_mc.gotoAndStop(4);
               }
               break;
            case "sunny":
               if(m_window.mainWindow.hasOwnProperty("Logo_mc"))
               {
                  m_window.mainWindow.Logo_mc.gotoAndStop(5);
               }
               break;
            case "jacques":
               if(m_window.mainWindow.hasOwnProperty("Logo_mc"))
               {
                  m_window.mainWindow.Logo_mc.gotoAndStop(6);
               }
         }
         if(m_window.mainWindow.hasOwnProperty("back_mc"))
         {
            m_window.mainWindow.back_mc.visible = true;
            m_window.mainWindow.back_mc.gotoAndPlay(2);
         }
         var item:FarmItem = Global.charityManager.getCharityItem();
         if(Boolean(item) && Boolean(m_window.mainWindow.hasOwnProperty("slot_0_mc")))
         {
            addWidget(new ObjectPreviewFrame(m_window.mainWindow.slot_0_mc,item,null,[2.5]));
         }
      }
      
      private function onLinkClicked(event:Event) : void
      {
         navigateToURL(new URLRequest(Global.charityManager.url),"_blank");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}

