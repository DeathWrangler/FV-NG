package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Managers.GuildEventManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildEventBuildingGrantWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BODY2_TF:String = "body2_tf";
      
      private var m_featureName:String;
      
      private var m_bonusArray_mc:Array;
      
      private var m_grantedBonus:FarmItem;
      
      private var m_tierLevel:int;
      
      private var m_jumpNPC:MovieClip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_backgroundMc:MovieClip;
      
      public function GuildEventBuildingGrantWindow(featureName:String, assetPath:String, buildingItem:FarmItem, tierLevel:int)
      {
         this.m_featureName = featureName;
         this.m_grantedBonus = buildingItem;
         this.m_tierLevel = tierLevel;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var child:MovieClip = null;
         var grandChild:MovieClip = null;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         var curTier:int = this.eventManager.getCurrentTier();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.TITLE_TF].text = "Mystery Unfolded";
            }
            else
            {
               m_window[this.TITLE_TF].text = "Map Destroyed!";
            }
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.BODY_TF].text = "You’ve found the lost fortune and uncovered these relics!";
            }
            else
            {
               m_window[this.BODY_TF].text = "Sorry Farmer! time is up and the map is now destroyed. You couldn’t salvage everything, but you have won this for your bravery!";
            }
         }
         if(m_window.hasOwnProperty(this.BODY2_TF))
         {
            m_window[this.BODY2_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.BODY2_TF].text = "Go forth your journey and discover more such mysteries";
            }
            else
            {
               m_window[this.BODY2_TF].text = "his was no small feat. Time to celebrate and come back next time to get a bigger win!\n";
            }
         }
         addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Okay!",this.onCloseWindow));
         this.m_bonusArray_mc = [];
         for(var i:int = 0; i < 3; i++)
         {
            this.m_bonusArray_mc[i] = m_window["Bonus_" + (i + 1).toString()] as MovieClip;
            this.m_bonusArray_mc[i].visible = false;
         }
         var childIndex:int = 1;
         var grandChildIndex:int = 1;
         if(this.m_grantedBonus != null)
         {
            if(m_window.hasOwnProperty("jump_ani_mc"))
            {
               this.m_jumpNPC = m_window["jump_ani_mc"] as MovieClip;
               this.m_jumpNPC.visible = true;
               for(childIndex = 1; childIndex < this.m_jumpNPC.numChildren; childIndex++)
               {
                  child = this.m_jumpNPC.getChildAt(childIndex) as MovieClip;
                  if(child)
                  {
                     child.play();
                     for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
                     {
                        grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                        if(grandChild)
                        {
                           grandChild.play();
                        }
                     }
                  }
               }
               this.m_jumpNPC.play();
            }
         }
         if(m_window.hasOwnProperty("background_mc"))
         {
            this.m_backgroundMc = m_window["background_mc"] as MovieClip;
            this.m_backgroundMc.visible = true;
            if(curTier <= 2)
            {
               this.m_backgroundMc.gotoAndStop(curTier);
            }
            else
            {
               this.m_backgroundMc.gotoAndStop(3);
            }
         }
         this.showBonusReward();
      }
      
      private function showBonusReward() : void
      {
         for(var i:int = 0; i < 3; i++)
         {
            if(i == this.m_tierLevel - 1)
            {
               this.m_bonusArray_mc[i].visible = true;
            }
         }
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      private function onCloseWindow(e:Event) : void
      {
         super.close();
         GuildEventManager.getInstance().onGrantAllPendingRewards();
      }
   }
}

