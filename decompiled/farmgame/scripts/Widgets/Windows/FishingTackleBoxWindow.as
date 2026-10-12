package Widgets.Windows
{
   import Managers.FarmStatsManager;
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingTackleBoxWindow extends FarmWindow
   {
      
      private static const BAIT_ICONS:Array = ["smallcandy","richcottoncandy","rainbowmarshmallow"];
      
      private static const ROD_ICONS:Array = ["fruityrod","chocopretzelrod","candyhookrod"];
      
      private static const BOOST_ICONS:Array = ["fishnet","sonardevice"];
      
      private var m_rodUsage_tf:ZwTextField;
      
      private var m_baitUsage_tf:ZwTextField;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_okay_bt1:FarmAnimatedTextButton;
      
      private var m_okay_bt2:FarmAnimatedTextButton;
      
      private var m_arrow_mc:MovieClip;
      
      private var m_waterTile_bt:FarmAnimatedButton;
      
      private var m_fish_collection_bt:FarmAnimatedButton;
      
      private var m_change_equip_bt:FarmAnimatedButton;
      
      private var m_goFishPulseBt:FarmButton;
      
      private var m_tackleRodHitArea:ZwFrame;
      
      private var m_tackleBaitHitArea:ZwFrame;
      
      private var m_tackleBootHitArea:ZwFrame;
      
      private var m_go_fish_tut_bt:FarmButton;
      
      public function FishingTackleBoxWindow(assetPath:String)
      {
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var baitIndex:int = 0;
         var baitName:String = null;
         var addBait:MovieClip = null;
         var baitIcon:FarmIcon = null;
         var rodIndex:int = 0;
         var rodName:String = null;
         var addRod:MovieClip = null;
         var rodIcon:FarmIcon = null;
         var boostIndex:int = 0;
         var boostName:String = null;
         var addBoost:MovieClip = null;
         var boostIcon:FarmIcon = null;
         var startGameBT:ZwWidget = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Fishing Frenzy"));
         }
         if(m_window.hasOwnProperty("new_tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["new_tutorial_mc"] as MovieClip;
            this.m_okay_bt1 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_0_bt,"Next",this.onOkay1Click);
            this.m_okay_bt2 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_1_bt,"Next",this.onOkay2Click);
            this.m_go_fish_tut_bt = new FarmButton(this.m_tutorial_mc.go_fish_tut_bt,this.onClickMiniGame) as FarmButton;
            this.m_arrow_mc = this.m_tutorial_mc.arrow_mc as MovieClip;
            if(FishingV2Manager.isTutorial1Over())
            {
               this.m_tutorial_mc.visible = false;
            }
            else
            {
               this.m_tutorial_mc.gotoAndStop(1);
               FishingV2Manager.m_selectedRod = 0;
               FishingV2Manager.m_selectedBait = 2;
               this.m_tutorial_mc.visible = true;
               this.m_okay_bt1.visible = true;
               this.m_okay_bt2.visible = false;
               this.m_arrow_mc.visible = true;
               this.m_go_fish_tut_bt.visible = false;
            }
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"Check your equipments here before you go fishing!"));
         }
         if(m_window.hasOwnProperty("go_fish_pulse_bt"))
         {
            this.m_goFishPulseBt = new FarmButton(m_window["go_fish_pulse_bt"],this.onClickMiniGame) as FarmButton;
         }
         if(FishingV2Manager.m_selectedBait != -1 && FishingV2Manager.m_selectedRod != -1)
         {
            if(FishingV2Manager.isTutorial1Over())
            {
               this.m_goFishPulseBt.visible = true;
            }
            else
            {
               this.m_goFishPulseBt.visible = false;
            }
         }
         if(m_window.hasOwnProperty("equip_status_mc"))
         {
            addWidget(new ZwBaseWidget(m_window.equip_status_mc));
            if(m_window.equip_status_mc.hasOwnProperty("change_equip_bt"))
            {
               addWidget(this.m_change_equip_bt = new FarmAnimatedButton(m_window.equip_status_mc["change_equip_bt"],this.changeEquipment));
               this.m_change_equip_bt.visible = true;
            }
            if(m_window.equip_status_mc.tackle_bait_mc)
            {
               baitIndex = FishingV2Manager.m_selectedBait;
               baitName = baitIndex != -1 ? FishingV2Manager.BAIT_NAMES[baitIndex] : "";
               addWidget(new ZwBaseWidget(m_window.equip_status_mc.tackle_bait_mc));
               if(m_window.equip_status_mc.tackle_bait_mc.add_item_mc)
               {
                  addBait = m_window.equip_status_mc.tackle_bait_mc.add_item_mc as MovieClip;
                  addBait.visible = FishingV2Manager.m_selectedBait == -1;
                  if(FishingV2Manager.m_selectedBait == -1)
                  {
                     addBait.addEventListener(MouseEvent.CLICK,this.changeEquipment);
                  }
               }
               if(m_window.equip_status_mc.tackle_bait_mc.bait_tf)
               {
                  addWidget(new ZwTextField(m_window.equip_status_mc.tackle_bait_mc.bait_tf,baitName));
               }
               if(m_window.equip_status_mc.tackle_bait_mc.equipped_icon_mc)
               {
                  baitIcon = new FarmIcon(m_window.equip_status_mc.tackle_bait_mc.equipped_icon_mc);
                  baitIcon.visible = true;
                  if(baitIndex != -1)
                  {
                     baitIcon.loadIcon(Global.getAssetURL("assets/newsfeed/" + BAIT_ICONS[baitIndex] + ".png"));
                     baitIcon.fitIconInsideBounds(50,50);
                  }
               }
               if(m_window.equip_status_mc.tackle_bait_mc.hasOwnProperty("tackle_hit_area_mc"))
               {
                  this.m_tackleBaitHitArea = new ZwFrame(m_window.equip_status_mc.tackle_bait_mc["tackle_hit_area_mc"]) as ZwFrame;
                  this.m_tackleBaitHitArea.visible = true;
                  if(FishingV2Manager.m_selectedBait == -1)
                  {
                     this.m_tackleBaitHitArea.addEventListener(MouseEvent.CLICK,this.changeEquipment);
                  }
               }
            }
            if(m_window.equip_status_mc.tackle_rods_mc)
            {
               rodIndex = FishingV2Manager.m_selectedRod;
               rodName = rodIndex != -1 ? FishingV2Manager.RODS_NAMES[rodIndex] : "";
               addWidget(new ZwBaseWidget(m_window.equip_status_mc.tackle_rods_mc));
               if(m_window.equip_status_mc.tackle_rods_mc.rod_tf)
               {
                  addWidget(new ZwTextField(m_window.equip_status_mc.tackle_rods_mc.rod_tf,rodName));
               }
               if(m_window.equip_status_mc.tackle_rods_mc.uses_tf)
               {
                  addWidget(new ZwTextField(m_window.equip_status_mc.tackle_rods_mc.uses_tf,"x" + FishingV2Manager.getInstance().getRemainingRodUses().toString()));
               }
               if(m_window.equip_status_mc.tackle_rods_mc.add_item_mc)
               {
                  addRod = m_window.equip_status_mc.tackle_rods_mc.add_item_mc as MovieClip;
                  addRod.visible = FishingV2Manager.m_selectedRod == -1;
                  if(FishingV2Manager.m_selectedRod == -1)
                  {
                     addRod.addEventListener(MouseEvent.CLICK,this.changeEquipment);
                  }
               }
               if(m_window.equip_status_mc.tackle_rods_mc.equipped_icon_mc)
               {
                  rodIcon = new FarmIcon(m_window.equip_status_mc.tackle_rods_mc.equipped_icon_mc);
                  rodIcon.visible = true;
                  if(rodIndex != -1)
                  {
                     rodIcon.loadIcon(Global.getAssetURL("assets/newsfeed/" + ROD_ICONS[rodIndex] + ".png"));
                     rodIcon.fitIconInsideBounds(50,50);
                  }
               }
               if(m_window.equip_status_mc.tackle_rods_mc.hasOwnProperty("tackle_hit_area_mc"))
               {
                  this.m_tackleRodHitArea = new ZwFrame(m_window.equip_status_mc.tackle_rods_mc["tackle_hit_area_mc"]) as ZwFrame;
                  this.m_tackleRodHitArea.visible = true;
               }
               if(m_window.equip_status_mc.tackle_rods_mc.uses_tf)
               {
                  this.m_rodUsage_tf = new ZwTextField(m_window.equip_status_mc.tackle_rods_mc.uses_tf,"x" + FishingV2Manager.getInstance().getRemainingRodUses().toString() + " uses");
                  if(FishingV2Manager.getInstance().getRemainingRodUses() >= 0)
                  {
                     if(FishingV2Manager.getInstance().getRemainingRodUses() == 0)
                     {
                        this.m_rodUsage_tf.text = "x4 uses";
                     }
                     this.m_rodUsage_tf.visible = true;
                  }
                  else
                  {
                     this.m_rodUsage_tf.visible = false;
                  }
               }
            }
            if(m_window.equip_status_mc.tackle_boosts_mc)
            {
               boostIndex = FishingV2Manager.m_selectedBoost;
               boostName = boostIndex != -1 ? FishingV2Manager.BOOSTS_NAMES[boostIndex] : "";
               addWidget(new ZwBaseWidget(m_window.equip_status_mc.tackle_boosts_mc));
               if(m_window.equip_status_mc.tackle_boosts_mc.boost_tf)
               {
                  addWidget(new ZwTextField(m_window.equip_status_mc.tackle_boosts_mc.boost_tf,boostName));
               }
               if(m_window.equip_status_mc.tackle_boosts_mc.add_item_mc)
               {
                  addBoost = m_window.equip_status_mc.tackle_boosts_mc.add_item_mc as MovieClip;
                  addBoost.visible = FishingV2Manager.m_selectedBoost == -1;
                  if(FishingV2Manager.m_selectedBoost == -1)
                  {
                     addBoost.addEventListener(MouseEvent.CLICK,this.changeEquipment);
                  }
               }
               if(m_window.equip_status_mc.tackle_boosts_mc.equipped_icon_mc)
               {
                  boostIcon = new FarmIcon(m_window.equip_status_mc.tackle_boosts_mc.equipped_icon_mc);
                  boostIcon.visible = true;
                  if(boostIndex != -1)
                  {
                     boostIcon.loadIcon(Global.getAssetURL("assets/newsfeed/" + BOOST_ICONS[boostIndex] + ".png"));
                     boostIcon.fitIconInsideBounds(50,50);
                  }
               }
               if(m_window.equip_status_mc.tackle_boosts_mc.hasOwnProperty("tackle_hit_area_mc"))
               {
                  this.m_tackleBootHitArea = new ZwFrame(m_window.equip_status_mc.tackle_boosts_mc["tackle_hit_area_mc"]) as ZwFrame;
                  this.m_tackleBootHitArea.visible = true;
               }
            }
         }
         if(this.m_tackleRodHitArea)
         {
            if(FishingV2Manager.m_selectedRod == -1)
            {
               this.m_tackleRodHitArea.attachTooltip(new FarmTextTooltip("Go to Equipment Shop to Equip"));
            }
            else
            {
               this.m_tackleRodHitArea.attachTooltip(new FarmTextTooltip("Go to Equipment Shop to change."));
            }
         }
         if(this.m_tackleBaitHitArea)
         {
            if(FishingV2Manager.m_selectedBait == -1)
            {
               this.m_tackleBaitHitArea.attachTooltip(new FarmTextTooltip("Go to Equipment Shop to Equip"));
            }
            else
            {
               this.m_tackleBaitHitArea.attachTooltip(new FarmTextTooltip("Go to Equipment Shop to change."));
            }
         }
         if(this.m_tackleBootHitArea)
         {
            if(FishingV2Manager.m_selectedBoost == -1)
            {
               this.m_tackleBootHitArea.attachTooltip(new FarmTextTooltip("Go to Equipment Shop to Equip"));
            }
            else
            {
               this.m_tackleBootHitArea.attachTooltip(new FarmTextTooltip("Go to Equipment Shop to change."));
            }
         }
         if(m_window.hasOwnProperty("go_fish_bt"))
         {
            startGameBT = addWidget(new ZwWidget(m_window["go_fish_bt"])) as ZwWidget;
            if(startGameBT.tooltip)
            {
               startGameBT.tooltip.release();
            }
            startGameBT.detachTooltip();
            if(FishingV2Manager.m_selectedBait != -1 && FishingV2Manager.m_selectedRod != -1)
            {
               (m_window["go_fish_bt"] as MovieClip).visible = false;
               this.m_goFishPulseBt.visible = true;
               (m_window["go_fish_bt"] as MovieClip).gotoAndStop(1);
               (m_window["go_fish_bt"] as MovieClip).addEventListener(MouseEvent.CLICK,function(event:Event):void
               {
                  if(FishingV2Manager.m_selectedBait != -1 && FishingV2Manager.m_selectedRod != -1)
                  {
                     FishingV2Manager.getInstance().openMiniGame();
                     close();
                  }
               });
            }
            else
            {
               startGameBT.attachTooltip(new FarmTextTooltip("Equip the tools to go fishing!"));
               (m_window["go_fish_bt"] as MovieClip).gotoAndStop(2);
            }
         }
         if(m_window.hasOwnProperty("water_tile_bt"))
         {
            addWidget(this.m_waterTile_bt = new FarmAnimatedButton(m_window["water_tile_bt"],this.onWaterTileButtonClick));
            if(FishingV2Manager.getInstance().canApplySonarBooseter() == false)
            {
               this.m_waterTile_bt.visible = false;
            }
            else
            {
               this.m_waterTile_bt.visible = true;
            }
            if(FishingV2Manager.getInstance().isP12TileUnlocked())
            {
               this.m_waterTile_bt.attachTooltip(new FarmTextTooltip("You have double the chance of getting a Rare fish!"));
            }
            else
            {
               this.m_waterTile_bt.attachTooltip(new FarmTextTooltip("Increase your chance of catching a Rare fish!"));
            }
         }
         if(m_window.hasOwnProperty("bait_shop_bt"))
         {
            addWidget(this.m_fish_collection_bt = new FarmAnimatedButton(m_window["bait_shop_bt"],this.onFishingCollectionButtonClick));
         }
      }
      
      public function onOkay1Click(e:Event = null) : void
      {
         this.m_okay_bt2.visible = true;
         this.m_okay_bt1.visible = false;
         this.m_go_fish_tut_bt.visible = false;
         this.m_tutorial_mc.gotoAndStop(2);
      }
      
      public function onOkay2Click(e:Event = null) : void
      {
         this.m_okay_bt2.visible = false;
         this.m_tutorial_mc.gotoAndStop(3);
         this.m_go_fish_tut_bt.visible = true;
      }
      
      public function onWaterTileButtonClick(e:Event) : void
      {
         if(FishingV2Manager.isTutorial1Over() == true)
         {
            FarmStatsManager.count("FishingV2","mainui","2xboost");
            FishingV2Manager.getInstance().showWaterTileBoostWindow();
         }
      }
      
      public function onClickMiniGame(e:Event) : void
      {
         FishingV2Manager.getInstance().openMiniGame();
         close();
      }
      
      public function onFishingCollectionButtonClick(e:Event) : void
      {
         if(FishingV2Manager.isTutorial1Over() == true)
         {
            FishingV2Manager.getInstance().showFishCollectionsWindow();
            close();
         }
      }
      
      private function changeEquipment(event:Event) : void
      {
         if(FishingV2Manager.isTutorial1Over() == true)
         {
            FarmStatsManager.count("FishingV2","mainui","equipmentshop");
            FishingV2Manager.getInstance().openCraftingWindow();
            close();
         }
      }
   }
}

