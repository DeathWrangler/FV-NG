package Widgets.Windows
{
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FishingCollectionFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingCollectionWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_baitShop_bt:FarmAnimatedButton;
      
      private var m_closeBt:FarmAnimatedButton;
      
      private var common_fish_mc:FishingCollectionFrame;
      
      private var uncommon_fish_mc:FishingCollectionFrame;
      
      private var rare_fish_mc:FishingCollectionFrame;
      
      private var reward0Mc:ZwFrame;
      
      private var reward1Mc:ZwFrame;
      
      private var m_lock_ing_mc:MovieClip;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_okay_bt1:FarmAnimatedTextButton;
      
      private var m_okay_bt2:FarmAnimatedTextButton;
      
      private var m_arrow_mc:MovieClip;
      
      private var m_okay_bt3:FarmAnimatedTextButton;
      
      private var m_waterTile_bt:FarmAnimatedButton;
      
      public var m_checkmark_mc_collection:MovieClip;
      
      public var m_checkmark_mc_mastery:MovieClip;
      
      public var m_collectionHoverMc:MovieClip;
      
      public var m_masteryHoverMc:MovieClip;
      
      private var m_collectionHovetTf:ZwTextField;
      
      private var m_MasteryHoverTf:ZwTextField;
      
      public var m_isClose:int = 0;
      
      public function FishingCollectionWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Fishing Lodge"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            if(FishingV2Manager.getInstance().isMasteryTrophyGranted() == 1)
            {
               addWidget(new ZwTextField(m_window["body_tf"],"Congrats! You have mastered all the fishes in this lake! Check your Gift Box for Rewards!"));
            }
            else
            {
               addWidget(new ZwTextField(m_window["body_tf"],"Master the fishes to get them as rewards!"));
            }
         }
         if(m_window.hasOwnProperty("new_tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["new_tutorial_mc"] as MovieClip;
            this.m_okay_bt1 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_0_bt,"Next",this.onOkay1Click);
            this.m_okay_bt2 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_1_bt,"Next",this.onOkay2Click);
            this.m_okay_bt3 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_2_bt,"Next",this.onOkay3Click);
            this.m_arrow_mc = this.m_tutorial_mc.arrow_mc as MovieClip;
            if(FishingV2Manager.isTutorial2Over())
            {
               this.m_tutorial_mc.visible = false;
            }
            else
            {
               this.m_tutorial_mc.visible = true;
               this.m_tutorial_mc.gotoAndStop(1);
               this.m_okay_bt1.visible = true;
               this.m_okay_bt2.visible = false;
               this.m_okay_bt3.visible = false;
               this.m_arrow_mc.visible = true;
            }
         }
         if(m_window.hasOwnProperty("collection_hover_mc"))
         {
            this.m_collectionHoverMc = m_window["collection_hover_mc"] as MovieClip;
            if(this.m_collectionHoverMc.hasOwnProperty("collection_hover_tf"))
            {
               this.m_collectionHovetTf = new ZwTextField(this.m_collectionHoverMc["collection_hover_tf"],"");
            }
         }
         if(m_window.hasOwnProperty("mastery_hover_mc"))
         {
            this.m_masteryHoverMc = m_window["mastery_hover_mc"] as MovieClip;
            if(this.m_masteryHoverMc.hasOwnProperty("mastery_hover_tf"))
            {
               this.m_MasteryHoverTf = new ZwTextField(this.m_masteryHoverMc["mastery_hover_tf"],"");
            }
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Master the fishes to get them as rewards!"));
         }
         if(m_window.hasOwnProperty("back_bt"))
         {
            addWidget(this.m_baitShop_bt = new FarmAnimatedButton(m_window["back_bt"],this.onBaitShopClick));
            this.m_baitShop_bt.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window["close_bt"].visible = false;
         }
         this.common_fish_mc = new FishingCollectionFrame(m_window["common_fish_mc"],this.m_featureName,0,this);
         this.common_fish_mc.visible = true;
         this.uncommon_fish_mc = new FishingCollectionFrame(m_window["uncommon_fish_mc"],this.m_featureName,1,this);
         this.uncommon_fish_mc.visible = true;
         this.rare_fish_mc = new FishingCollectionFrame(m_window["rare_fish_mc"],this.m_featureName,2,this);
         this.rare_fish_mc.visible = true;
         if(m_window.hasOwnProperty("lock_ing_mc"))
         {
            this.m_lock_ing_mc = m_window.lock_ing_mc as MovieClip;
            this.m_lock_ing_mc.visible = true;
         }
         if(m_window.hasOwnProperty("water_tile_bt"))
         {
            addWidget(this.m_waterTile_bt = new FarmAnimatedButton(m_window["water_tile_bt"],this.onWaterTileButtonClick));
            if(FishingV2Manager.getInstance().isP12TileUnlocked())
            {
               this.m_waterTile_bt.attachTooltip(new FarmTextTooltip("You have double the chance of getting a Rare fish!"));
            }
            else
            {
               this.m_waterTile_bt.attachTooltip(new FarmTextTooltip("Increase your chance of catching a Rare fish!"));
            }
         }
         if(m_window.hasOwnProperty("reward_0_mc"))
         {
            this.reward0Mc = new ZwFrame(m_window["reward_0_mc"]);
            this.reward0Mc.visible = true;
            this.reward0Mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverMastery());
            this.reward0Mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutMastry());
            if(FishingV2Manager.getInstance().isMasteryTrophyGranted() == 1)
            {
               if(FishingV2Manager.getInstance().canHarvestMasteryTrophy())
               {
                  this.m_MasteryHoverTf.text = "Cocostone Bass Trophy - You have mastered this trophy! Harvestable for next " + HUD.getformattedTimeLeft(FishingV2Manager.getInstance().getTimeLeftForFinalHarvestOfMasteryTrophy()) + ".";
               }
               else
               {
                  this.m_MasteryHoverTf.text = "Cocostone Bass Trophy - You have mastered this trophy!";
               }
            }
            else
            {
               this.m_MasteryHoverTf.text = "Cocostone Bass Trophy - Master all the fishes to get this trophy!";
            }
            if(m_window.reward_0_mc.hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmark_mc_mastery = m_window.reward_0_mc["checkmark_mc"] as MovieClip;
               this.m_checkmark_mc_mastery.visible = FishingV2Manager.getInstance().isMasteryTrophyGranted();
            }
         }
         if(m_window.hasOwnProperty("reward_1_mc"))
         {
            this.reward1Mc = new ZwFrame(m_window["reward_1_mc"]);
            this.reward1Mc.visible = true;
            this.reward1Mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
            this.reward1Mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            if(FishingV2Manager.getInstance().isCollectionTrophyGranted() == 1)
            {
               if(FishingV2Manager.getInstance().canHarvestCollectionTrophy())
               {
                  this.m_collectionHovetTf.text = "Cocostone Bass Trophy - You have mastered this trophy! Harvestable for next " + HUD.getformattedTimeLeft(FishingV2Manager.getInstance().getTimeLeftForFinalHarvestOfCollectionTrophy()) + ".";
               }
               else
               {
                  this.m_collectionHovetTf.text = "Cotton Candy Betta Trophy - You have mastered this trophy!";
               }
            }
            else
            {
               this.m_collectionHovetTf.text = "Cotton Candy Betta Trophy - Collect one of each fish to get this trophy!";
            }
            if(m_window.reward_1_mc.hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmark_mc_collection = m_window.reward_1_mc["checkmark_mc"] as MovieClip;
               this.m_checkmark_mc_collection.visible = FishingV2Manager.getInstance().isCollectionTrophyGranted();
            }
         }
         if(FishingV2Manager.getInstance().canApplySonarBooseter() == false)
         {
            this.m_waterTile_bt.visible = false;
         }
         else
         {
            this.m_waterTile_bt.visible = true;
         }
         var featureData:Object = FishingV2Manager.getInstance().getFeatureData();
         if(Boolean(featureData && featureData.hasOwnProperty("MasteryReward")) && Boolean(featureData["MasteryReward"] == 1) || FishingV2Manager.getInstance().canApplySonarBooseter() == false)
         {
            this.m_waterTile_bt.visible = false;
         }
         else
         {
            this.m_waterTile_bt.visible = true;
         }
      }
      
      public function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_collectionHoverMc.visible = true;
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_collectionHoverMc.visible = false;
         };
      }
      
      public function onMouseOverMastery() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_masteryHoverMc.visible = true;
         };
      }
      
      public function onMouseOutMastry() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_masteryHoverMc.visible = false;
         };
      }
      
      public function onWaterTileButtonClick(e:Event) : void
      {
         FarmStatsManager.count(this.m_featureName,"FishingLodge","2xboost","click");
         FishingV2Manager.getInstance().showWaterTileBoostWindow();
      }
      
      private function onBaitShopClick(event:Event) : void
      {
         this.close();
      }
      
      private function onCloseBt(event:Event) : void
      {
         this.close();
      }
      
      override public function refreshWindow() : void
      {
         this.common_fish_mc.refresh();
         this.uncommon_fish_mc.refresh();
         this.rare_fish_mc.refresh();
         if(this.m_checkmark_mc_mastery)
         {
            this.m_checkmark_mc_mastery.visible = FishingV2Manager.getInstance().isMasteryTrophyGranted();
         }
         if(this.m_checkmark_mc_collection)
         {
            this.m_checkmark_mc_collection.visible = FishingV2Manager.getInstance().isCollectionTrophyGranted();
         }
         if(FishingV2Manager.getInstance().isMasteryTrophyGranted() == 1)
         {
            if(FishingV2Manager.getInstance().canHarvestMasteryTrophy())
            {
               this.m_MasteryHoverTf.text = "Cocostone Bass Trophy - You have mastered this trophy! Harvestable for next " + HUD.getformattedTimeLeft(FishingV2Manager.getInstance().getTimeLeftForFinalHarvestOfMasteryTrophy()) + ".";
            }
            else
            {
               this.m_MasteryHoverTf.text = "Cocostone Bass Trophy - You have mastered this trophy!";
            }
         }
         else
         {
            this.m_MasteryHoverTf.text = "Cocostone Bass Trophy - Master all the fishes to get this trophy!";
         }
         if(FishingV2Manager.getInstance().isCollectionTrophyGranted() == 1)
         {
            if(FishingV2Manager.getInstance().canHarvestCollectionTrophy())
            {
               this.m_collectionHovetTf.text = "Cotton Candy Betta Trophy - You have mastered this trophy! Harvestable for next " + HUD.getformattedTimeLeft(FishingV2Manager.getInstance().getTimeLeftForFinalHarvestOfCollectionTrophy()) + ".";
            }
            else
            {
               this.m_collectionHovetTf.text = "Cotton Candy Betta Trophy - You have mastered this trophy!";
            }
         }
         else
         {
            this.m_collectionHovetTf.text = "Cotton Candy Betta Trophy - Collect one of each fish to get this trophy!";
         }
      }
      
      public function onOkay1Click(e:Event = null) : void
      {
         this.m_okay_bt2.visible = true;
         this.m_okay_bt1.visible = false;
         this.m_tutorial_mc.gotoAndStop(2);
      }
      
      public function onOkay2Click(e:Event = null) : void
      {
         this.m_okay_bt3.visible = true;
         this.m_okay_bt2.visible = false;
         this.m_tutorial_mc.gotoAndStop(3);
      }
      
      public function onOkay3Click(e:Event = null) : void
      {
         this.m_tutorial_mc.visible = false;
         this.close();
         FishingV2Manager.getInstance().openCraftingWindow();
      }
      
      override protected function afterLoad() : void
      {
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window["close_bt"].visible = false;
         }
         if(FishingV2Manager.getInstance().isMasteryTrophyGranted())
         {
            m_window["close_bt"].visible = true;
            if(this.m_baitShop_bt)
            {
               this.m_baitShop_bt.visible = false;
            }
         }
      }
      
      override public function close() : void
      {
         var featureData:Object = FishingV2Manager.getInstance().getFeatureData();
         if(!(Boolean(featureData) && Boolean(featureData.hasOwnProperty("MasteryReward")) && featureData["MasteryReward"] == 1))
         {
            if(this.m_isClose != 1)
            {
               if(FishingV2Manager.isTutorial2Over())
               {
                  FishingV2Manager.getInstance().showMainUI();
               }
            }
         }
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}

