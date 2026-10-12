package HolidayCountdown
{
   import Classes.util.ZLocUtils;
   import Display.QueuedIcon;
   import Managers.HolidayCountdownManager;
   import Widgets.Core.Managers.ZwWidgetManager;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class HolidayCountdownMessageIcon extends QueuedIcon
   {
      
      protected static const ATTRACT_TIME:int = 5000;
      
      protected var m_attractMovieClip:MovieClip;
      
      protected var m_messageMovieClip:MovieClip;
      
      protected var m_attractTimer:Timer;
      
      protected var m_message:String = "";
      
      protected var m_mode:int = -1;
      
      protected var m_helperIcon:String = "";
      
      protected var m_giftIcon:String = "";
      
      protected var m_checkMarkMovieClip:MovieClip;
      
      private var m_widgetManager:ZwWidgetManager = new ZwWidgetManager();
      
      public function HolidayCountdownMessageIcon(xml:XML)
      {
         super(xml);
      }
      
      public function get mode() : int
      {
         return this.m_mode;
      }
      
      override public function init() : void
      {
         var hudIconIndex:int = 0;
         super.init();
         if(Boolean(extraData) && extraData.hasOwnProperty("hudIconIndex"))
         {
            hudIconIndex = int(extraData.hudIconIndex);
            this.m_helperIcon = extraData.helperItemIcon;
            this.m_giftIcon = extraData.giftItemIcon;
            this.m_mode = hudIconIndex;
         }
      }
      
      override protected function onButtonIconLoaded(event:Event) : void
      {
         var itemHelper:FarmIcon = null;
         var itemReward:FarmIcon = null;
         var itemMessHelper:FarmIcon = null;
         var itemMessReward:FarmIcon = null;
         super.onButtonIconLoaded(event);
         this.m_attractMovieClip = (m_Loader.content as MovieClip).hud_attract_mc;
         if(Boolean(this.m_attractMovieClip["ticketicon_mc"]) && Boolean(this.m_attractMovieClip.ticketicon_mc["icon_mc"]))
         {
            itemHelper = this.m_widgetManager.addWidget(new FarmIcon(this.m_attractMovieClip.ticketicon_mc.icon_mc)) as FarmIcon;
            itemHelper.loadIcon(this.m_helperIcon);
            itemHelper.visible = true;
         }
         if(this.m_attractMovieClip["prize_mc"])
         {
            itemReward = this.m_widgetManager.addWidget(new FarmIcon(this.m_attractMovieClip.prize_mc)) as FarmIcon;
            itemReward.loadIcon(this.m_giftIcon,this.updateHudNode);
            itemReward.visible = true;
         }
         this.m_messageMovieClip = null;
         if((m_Loader.content as MovieClip)["hud_message_mc"] != null)
         {
            this.m_messageMovieClip = (m_Loader.content as MovieClip).hud_message_mc;
            this.m_messageMovieClip.visible = false;
         }
         if(Boolean(this.m_messageMovieClip != null) && Boolean(this.m_messageMovieClip["ticketicon2_mc"]) && Boolean(this.m_messageMovieClip.ticketicon2_mc["icon2_mc"]))
         {
            itemMessHelper = this.m_widgetManager.addWidget(new FarmIcon(this.m_messageMovieClip.ticketicon2_mc.icon2_mc)) as FarmIcon;
            itemMessHelper.loadIcon(this.m_helperIcon);
            itemMessHelper.visible = true;
         }
         if(this.m_messageMovieClip != null && Boolean(this.m_messageMovieClip["prize2_mc"]))
         {
            itemMessReward = this.m_widgetManager.addWidget(new FarmIcon(this.m_messageMovieClip.prize2_mc)) as FarmIcon;
            itemMessReward.loadIcon(this.m_giftIcon);
            itemMessReward.visible = true;
         }
         this.m_checkMarkMovieClip = (m_Loader.content as MovieClip).checkmark_mc;
         this.m_attractTimer = new Timer(ATTRACT_TIME);
         this.updateHudNode();
      }
      
      private function updateHudNode() : void
      {
         switch(this.m_mode)
         {
            case HolidayCountdownIconStates.ATTRACT:
            case HolidayCountdownIconStates.NEW_GIFT:
            case HolidayCountdownIconStates.DAYS_LEFT:
               this.setupHudIcon();
               break;
            case HolidayCountdownIconStates.DAYS_LEFT:
               this.showDone();
               break;
            default:
               this.showDefault();
         }
      }
      
      protected function stopAttractTimer() : void
      {
         this.m_attractTimer.stop();
         this.m_attractTimer.removeEventListener(TimerEvent.TIMER,this.onAttractInterval);
      }
      
      protected function startAttractTimer() : void
      {
         if(this.m_mode == HolidayCountdownIconStates.ATTRACT)
         {
            this.m_attractTimer.addEventListener(TimerEvent.TIMER,this.onAttractInterval);
            this.m_attractTimer.start();
         }
         else
         {
            this.onAttractInterval(null);
         }
      }
      
      protected function onAttractInterval(event:TimerEvent) : void
      {
         this.m_attractMovieClip.gotoAndPlay(2);
      }
      
      protected function showDefault() : void
      {
         var daysLeft:int = 0;
         this.m_mode = HolidayCountdownIconStates.NONE;
         if(m_isLoaded)
         {
            this.stopAttractTimer();
            if(this.m_checkMarkMovieClip != null)
            {
               this.m_checkMarkMovieClip.visible = false;
            }
            this.m_attractMovieClip.visible = true;
            daysLeft = HolidayCountdownManager.extraDaysLeft();
            if(daysLeft != -1)
            {
               if(this.m_attractMovieClip["newPrize_tf"])
               {
                  this.m_attractMovieClip.newPrize_tf.visible = false;
               }
               if(this.m_attractMovieClip["daysLeft_mc"])
               {
                  this.m_attractMovieClip.daysLeft_mc.daysLeftcount_tf.text = daysLeft.toString();
               }
            }
            else if(this.m_attractMovieClip["daysLeft_mc"])
            {
               this.m_attractMovieClip.daysLeft_mc.visible = false;
            }
            this.m_attractMovieClip.gotoAndStop(2);
            if(this.m_messageMovieClip != null)
            {
               this.m_messageMovieClip.visible = false;
            }
         }
      }
      
      private function setupHudIcon(showPrizeText:Boolean = true) : void
      {
         var daysLeft:int = 0;
         var prizeText:String = null;
         if(m_isLoaded)
         {
            this.stopAttractTimer();
            if(this.m_checkMarkMovieClip != null)
            {
               this.m_checkMarkMovieClip.visible = false;
            }
            if(this.m_attractMovieClip != null)
            {
               this.m_attractMovieClip.visible = true;
            }
            if(this.m_messageMovieClip != null)
            {
               this.m_messageMovieClip.visible = false;
            }
            daysLeft = HolidayCountdownManager.extraDaysLeft();
            if(daysLeft != -1)
            {
               if(this.m_attractMovieClip["newPrize_tf"])
               {
                  this.m_attractMovieClip.newPrize_tf.visible = false;
               }
               if(this.m_attractMovieClip["daysLeft_mc"])
               {
                  this.m_attractMovieClip.daysLeft_mc.daysLeftcount_tf.text = daysLeft.toString();
               }
            }
            else
            {
               if(this.m_attractMovieClip["newPrize_tf"])
               {
                  prizeText = showPrizeText ? ZLocUtils.t("HolidayCountdown","HolidayCountdown_hudIconNewGift") : "";
                  this.m_attractMovieClip.newPrize_tf.text = prizeText;
               }
               if(this.m_attractMovieClip["daysLeft_mc"])
               {
                  this.m_attractMovieClip.daysLeft_mc.visible = false;
               }
            }
            this.startAttractTimer();
         }
      }
      
      public function showAttractMode(showPrizeText:Boolean = false) : void
      {
         this.m_mode = HolidayCountdownIconStates.ATTRACT;
         this.setupHudIcon(showPrizeText);
      }
      
      protected function showDone() : void
      {
         var daysLeft:int = 0;
         this.m_mode = HolidayCountdownIconStates.DONE;
         if(m_isLoaded)
         {
            if(this.m_checkMarkMovieClip != null)
            {
               this.m_checkMarkMovieClip.visible = true;
            }
            this.m_attractMovieClip.visible = true;
            daysLeft = HolidayCountdownManager.extraDaysLeft();
            if(daysLeft != -1)
            {
               if(this.m_attractMovieClip["newPrize_tf"])
               {
                  this.m_attractMovieClip.newPrize_tf.visible = false;
               }
               if(this.m_attractMovieClip["daysLeft_mc"])
               {
                  this.m_attractMovieClip.daysLeft_mc.daysLeftcount_tf.text = daysLeft.toString();
               }
            }
            else if(this.m_attractMovieClip["daysLeft_mc"])
            {
               this.m_attractMovieClip.daysLeft_mc.visible = false;
            }
            this.m_attractMovieClip.gotoAndStop(2);
            this.m_messageMovieClip.visible = false;
         }
      }
   }
}

