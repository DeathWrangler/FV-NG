package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CocowonderlandInnovationFinalRewardGrantWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_finalProgress:int = 0;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      private var m_bonus_reward_mc:MovieClip;
      
      private var m_bonus_1_mc:MovieClip;
      
      private var m_bonus_2_mc:MovieClip;
      
      private var m_bonus_3_mc:MovieClip;
      
      private var m_bonus_1_spot:ZwFrame;
      
      private var m_bonus_2_spot:ZwFrame;
      
      private var m_bonus_3_spot:ZwFrame;
      
      private var m_idle_ani_mc:MovieClip;
      
      private var m_level_mc:MovieClip;
      
      private var m_consumable1_ani:MovieClip;
      
      private var m_consumable2_ani:MovieClip;
      
      private var m_consumable3_ani:MovieClip;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_level:Array = ["Baker","Sous Chef","Patissier"];
      
      private var m_bonusBuildings:Array = ["Bakers Haven","Cafe Espresso","Pop Patissiere"];
      
      public function CocowonderlandInnovationFinalRewardGrantWindow(dialogAsset:String, featureName:String, buttonCallback:Function = null, dialogBackground:String = null, progressAverage:int = 0)
      {
         super(dialogAsset);
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_finalProgress = progressAverage;
         if(dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String = null;
         var subText1:String = null;
         var subText2:String = null;
         var m_level_tf:ZwTextField = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               titleText = "A Sweet Finish!";
               if(this.m_finalProgress == -1)
               {
                  titleText = "Baking Ended";
               }
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],titleText)) as ZwTextField;
            }
            if(m_window.hasOwnProperty("body_tf"))
            {
               subText1 = "You are truly an amazing " + this.m_level[this.m_finalProgress] + "!\nYou have won the " + this.m_bonusBuildings[this.m_finalProgress] + ". Find it on your farm.";
               if(this.m_finalProgress == -1)
               {
                  subText1 = "Your baking season has now come to an end.";
               }
               addWidget(new ZwTextField(m_window["body_tf"],subText1));
            }
            if(m_window.hasOwnProperty("body2_tf"))
            {
               subText2 = "Harvest " + itemName + " every 24 hours to get any consumable shown above";
               if(this.m_finalProgress == -1)
               {
                  subText2 = "That was fun. It was great having you around!\n";
               }
               addWidget(new ZwTextField(m_window["body2_tf"],subText2));
            }
            if(this.m_finalProgress > -1)
            {
               if(m_window.hasOwnProperty("bonus_reward_mc"))
               {
                  this.m_bonus_reward_mc = m_window["bonus_reward_mc"] as MovieClip;
                  this.m_bonus_reward_mc.visible = true;
                  if(this.m_bonus_reward_mc.hasOwnProperty("Bonus_1"))
                  {
                     this.m_bonus_1_mc = this.m_bonus_reward_mc["Bonus_1"] as MovieClip;
                     this.m_bonus_1_mc.visible = false;
                     if(this.m_bonus_1_mc.hasOwnProperty("consumable_1_ani"))
                     {
                        this.m_consumable1_ani = this.m_bonus_1_mc["consumable_1_ani"] as MovieClip;
                        this.m_consumable1_ani.visible = false;
                     }
                  }
                  if(this.m_bonus_reward_mc.hasOwnProperty("Bonus_2"))
                  {
                     this.m_bonus_2_mc = this.m_bonus_reward_mc["Bonus_2"] as MovieClip;
                     this.m_bonus_2_mc.visible = false;
                     if(this.m_bonus_2_mc.hasOwnProperty("consumable_2_ani"))
                     {
                        this.m_consumable2_ani = this.m_bonus_2_mc["consumable_2_ani"] as MovieClip;
                        this.m_consumable2_ani.visible = false;
                     }
                  }
                  if(this.m_bonus_reward_mc.hasOwnProperty("Bonus_3"))
                  {
                     this.m_bonus_3_mc = this.m_bonus_reward_mc["Bonus_3"] as MovieClip;
                     this.m_bonus_3_mc.visible = false;
                     if(this.m_bonus_3_mc.hasOwnProperty("consumable_3_ani"))
                     {
                        this.m_consumable3_ani = this.m_bonus_3_mc["consumable_3_ani"] as MovieClip;
                        this.m_consumable3_ani.visible = false;
                     }
                  }
                  if(this.m_bonus_reward_mc.hasOwnProperty("level_mc"))
                  {
                     this.m_level_mc = this.m_bonus_reward_mc["level_mc"] as MovieClip;
                     this.m_level_mc.visible = true;
                     if(this.m_level_mc.hasOwnProperty("level_tf"))
                     {
                        m_level_tf = new ZwTextField(this.m_level_mc["level_tf"],this.m_level[this.m_finalProgress]);
                        m_level_tf.visible = true;
                     }
                  }
                  if(this.m_finalProgress == 0)
                  {
                     this.m_bonus_1_mc.visible = true;
                     this.m_consumable1_ani.visible = true;
                  }
                  else if(this.m_finalProgress == 1)
                  {
                     this.m_bonus_2_mc.visible = true;
                     this.m_consumable2_ani.visible = true;
                  }
                  else if(this.m_finalProgress == 2)
                  {
                     this.m_bonus_3_mc.visible = true;
                     this.m_consumable3_ani.visible = true;
                  }
               }
            }
            else if(this.m_finalProgress == -1)
            {
               if(m_window.hasOwnProperty("idle3_ani_mc"))
               {
                  this.m_idle_ani_mc = m_window["idle3_ani_mc"] as MovieClip;
                  this.m_idle_ani_mc.visible = true;
               }
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}

