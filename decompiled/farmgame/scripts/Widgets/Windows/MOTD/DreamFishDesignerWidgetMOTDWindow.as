package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class DreamFishDesignerWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      protected var m_whobt:FarmAnimatedTextButton;
      
      private var m_userPic:FarmIcon = null;
      
      public function DreamFishDesignerWidgetMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var uid:String = null;
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["accept_bt"])
            {
               this.m_whobt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc["accept_bt"],ZLocUtils.t_pk(m_currentMOTD["buttonText"]),this.onWhoButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc["icon_mc"])
            {
               uid = Global.player.uid;
               this.m_userPic = new FarmIcon(m_window.mainWindow.animation_mc["icon_mc"],"http://graph.facebook.com/v3.3/" + uid + "/picture?type=large");
               this.m_userPic.setIconSize(128,128);
            }
            if(m_window.mainWindow.animation_mc["close_bt"])
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.animation_mc["close_bt"],onClose)) as FarmButton;
            }
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
         }
      }
      
      protected function onWhoButtonClick(event:MouseEvent) : void
      {
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
      }
   }
}

