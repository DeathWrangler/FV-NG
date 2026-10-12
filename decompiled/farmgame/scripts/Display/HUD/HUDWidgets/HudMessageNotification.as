package Display.HUD.HUDWidgets
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.MessageBoardManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudMessageNotification extends HUDWidget
   {
      
      public static const STATE_IDLE:int = 0;
      
      public static const STATE_HARVEST_NOTIF:int = 1;
      
      private static const HUD_MC:String = "hud_mc";
      
      private var m_featureName:String = "MessageBoard";
      
      private var m_hudButton:FarmAnimatedButton;
      
      public var m_main_bell:MovieClip;
      
      private var m_notification_badge_mc:MovieClip;
      
      private var m_notification_tf:ZwTextField;
      
      private var m_state:int = -1;
      
      public function HudMessageNotification(assetPath:String)
      {
         super(assetPath,Global.hud);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var msgCount:int = 0;
         super.onLoadComplete(event);
         m_element.filters = [new DropShadowFilter()];
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.openUI),true);
            if(m_element[HUD_MC].hasOwnProperty("main_bell"))
            {
               this.m_main_bell = m_element[HUD_MC]["main_bell"] as MovieClip;
               this.m_main_bell.visible = true;
            }
            if(m_element[HUD_MC].hasOwnProperty("notificationbadge_mc"))
            {
               this.m_notification_badge_mc = m_element[HUD_MC]["notificationbadge_mc"] as MovieClip;
               this.m_notification_badge_mc.visible = false;
            }
            if(this.m_notification_badge_mc.hasOwnProperty("notification_no_tf"))
            {
               this.m_notification_tf = new ZwTextField(this.m_notification_badge_mc["notification_no_tf"],"10");
               this.m_notification_tf.visible = true;
            }
         }
         var featureData:* = MessageBoardManager.getInstance().getFeatureData();
         msgCount = int(featureData["msgCount"]);
         msgCount = msgCount ? msgCount : 0;
         var readMsg:Object = featureData["read_msgs"];
         if(featureData)
         {
            if(Boolean(featureData["active"]) && featureData["active"].length > 0)
            {
               if(Boolean(featureData.hasOwnProperty("read_msgs")) && Boolean(featureData["read_msgs"].length > 0) && msgCount > 0)
               {
                  this.startHudMovement();
                  this.m_notification_badge_mc.visible = true;
                  this.m_notification_tf.text = "" + msgCount;
               }
               else if(msgCount > 0)
               {
                  this.startHudMovement();
                  this.m_notification_badge_mc.visible = true;
                  this.m_notification_tf.text = "" + msgCount;
               }
               else
               {
                  this.stopHudMovement();
                  this.m_notification_badge_mc.visible = false;
               }
            }
            else
            {
               this.stopHudMovement();
               this.m_notification_badge_mc.visible = false;
            }
         }
         else
         {
            this.stopHudMovement();
         }
      }
      
      private function openUI(fevent:Event) : void
      {
         StatsManager.count(this.m_featureName,"","click",this.m_state.toString());
         MessageBoardManager.getInstance().showToasterHud();
         if(this.m_notification_badge_mc)
         {
            this.m_notification_badge_mc.visible = false;
         }
      }
      
      public function startHudMovement() : void
      {
         if(this.m_main_bell)
         {
            this.m_main_bell.visible = true;
            this.m_main_bell.gotoAndPlay(2);
         }
      }
      
      public function stopHudMovement() : void
      {
         if(this.m_main_bell)
         {
            this.m_main_bell.visible = true;
            this.m_main_bell.gotoAndStop(2);
         }
      }
      
      public function setXY() : void
      {
         var msgHudOffset:int = 0;
         if(m_loader)
         {
            msgHudOffset = 150;
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 + 160;
            m_loader.y = Global.stage.stageHeight - msgHudOffset;
         }
      }
      
      override public function release() : void
      {
         this.m_hudButton = null;
         super.release();
      }
   }
}

