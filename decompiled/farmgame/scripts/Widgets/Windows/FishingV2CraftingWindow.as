package Widgets.Windows
{
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FishingV2CraftingWindow extends FarmWindowWithTutorial
   {
      
      public static const FISH_TYPE:Array = ["Common","Uncommon","Rare"];
      
      private var m_featureName:String = null;
      
      private var m_titleTF:ZwTextField;
      
      private var m_bootCountTF:ZwTextField;
      
      private var m_bootRedeemBT:FarmAnimatedTextButton;
      
      private var m_timer:Timer;
      
      private var m_rodEquipButtons:Array = [];
      
      private var m_rodCraftMCs:Array = [];
      
      private var m_rodHighlightMCs:Array = [];
      
      private var m_rodSkipBTs:Array = [];
      
      private var m_rodCraftingButtons:Array = [];
      
      private var m_rodTimerTFs:Array = [];
      
      private var m_rodCountTFs:Array = [];
      
      private var m_baitEquipButtons:Array = [];
      
      private var m_baitHighlightMCs:Array = [];
      
      private var m_baitSkipBTs:Array = [];
      
      private var m_baitCraftMCs:Array = [];
      
      private var m_baitCraftingButtons:Array = [];
      
      private var m_baitTimerTFs:Array = [];
      
      private var m_baitCountTFs:Array = [];
      
      private var m_boostCountTFs:Array = [];
      
      private var m_boostHighlightMCs:Array = [];
      
      private var m_boostEquipButtons:Array = [];
      
      private var m_boostBuyButtons:Array = [];
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_okay_bt1:FarmAnimatedTextButton;
      
      private var m_arrow_mc:MovieClip;
      
      private var m_FTUEFrameNumber:int = 1;
      
      private var m_okay_bt2:FarmAnimatedTextButton;
      
      private var m_back_pulse_bt:FarmAnimatedButton;
      
      private var m_bootMc:ZwFrame;
      
      private var m_boostArray:Array = [];
      
      private var m_rodsArray:Array = [];
      
      private var m_baitsArray:Array = [];
      
      private var m_rodsBtArray:Array = [];
      
      private var m_baitsBtArray:Array = [];
      
      private var m_worldRewardTooltip:Array = [];
      
      private var m_rodsToolTip:Array = [];
      
      private var m_baitBt:FarmAnimatedTextButton;
      
      private var m_rodBt:FarmAnimatedTextButton;
      
      public function FishingV2CraftingWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         super(this.m_featureName,assetURL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window["title_tf"])
         {
            this.m_titleTF = addWidget(new ZwTextField(m_window["title_tf"],"Equipment Shop")) as ZwTextField;
            this.m_titleTF.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window["close_bt"].visible = false;
         }
         if(m_window.hasOwnProperty("back_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.back_bt,"",function(event:Event):void
            {
               close();
            }));
         }
         if(m_window.hasOwnProperty("back_pulse_bt"))
         {
            addWidget(this.m_back_pulse_bt = new FarmAnimatedButton(m_window["back_pulse_bt"],function(event:Event):void
            {
               close();
            }));
            this.m_back_pulse_bt.visible = true;
         }
         if(m_window.hasOwnProperty("boot_mc"))
         {
            if(m_window.boot_mc.hasOwnProperty("fish_icon_mc"))
            {
               this.m_bootMc = new ZwFrame(m_window.boot_mc["fish_icon_mc"]) as ZwFrame;
               this.m_bootMc.visible = true;
               this.m_bootMc.attachTooltip(new FarmTextTooltip("Exchange 4 for 1 Fruity Rod"));
            }
            if(m_window.boot_mc.rod_count_tf)
            {
               this.m_bootCountTF = new ZwTextField(m_window.boot_mc.rod_count_tf,FishingV2Manager.getInstance().getBootCount().toString()) as ZwTextField;
            }
            if(m_window.boot_mc.redeem_bt)
            {
               this.m_bootRedeemBT = addWidget(new FarmAnimatedTextButton(m_window.boot_mc.redeem_bt,"Redeem",this.onRedeemClick)) as FarmAnimatedTextButton;
               this.m_bootRedeemBT.enabled = FishingV2Manager.getInstance().canRedeemBoots();
            }
         }
         if(m_window.hasOwnProperty("all_rod_mc"))
         {
            this.initRodsFrame();
         }
         if(m_window.hasOwnProperty("all_bait_mc"))
         {
            this.initBaitsFrame();
         }
         if(m_window.hasOwnProperty("all_boost_mc"))
         {
            this.initBoostsFrame();
         }
         this.refreshWindow();
         this.startTimer();
         if(m_window.hasOwnProperty("new_tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["new_tutorial_mc"] as MovieClip;
            addWidget(this.m_okay_bt1 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_0_bt,"Next",this.onOkay1Click));
            addWidget(this.m_okay_bt2 = new FarmAnimatedTextButton(this.m_tutorial_mc.okay_1_bt,"Next",this.onOkay1Click));
            if(this.m_tutorial_mc.hasOwnProperty("candyhook_equip_bt"))
            {
               addWidget(this.m_rodBt = new FarmAnimatedTextButton(this.m_tutorial_mc.candyhook_equip_bt,"Equip",this.onSelectEquip(FishingV2Manager.TYPE_ROD,2)));
            }
            if(this.m_tutorial_mc.hasOwnProperty("rainbow_equip_bt"))
            {
               addWidget(this.m_baitBt = new FarmAnimatedTextButton(this.m_tutorial_mc.rainbow_equip_bt,"Equip",this.onSelectEquip(FishingV2Manager.TYPE_BAIT,2)));
            }
            this.m_rodBt.visible = false;
            this.m_baitBt.visible = false;
            this.m_arrow_mc = this.m_tutorial_mc.arrow_mc as MovieClip;
         }
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
            this.m_arrow_mc.visible = true;
         }
      }
      
      override protected function afterLoad() : void
      {
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window["close_bt"].visible = true;
         }
         if(FishingV2Manager.isTutorial1Over() == false)
         {
            m_window["close_bt"].visible = false;
         }
      }
      
      private function initBaitsFrame() : void
      {
         var baitSlot:MovieClip = null;
         var baitsFrame:MovieClip = m_window["all_bait_mc"] as MovieClip;
         var index:int = 0;
         while(baitsFrame["bait_" + index.toString() + "_mc"])
         {
            baitSlot = baitsFrame["bait_" + index.toString() + "_mc"] as MovieClip;
            if(baitSlot.equip_bt)
            {
               this.m_baitEquipButtons.push(new FarmAnimatedTextButton(baitSlot.equip_bt,"",this.onSelectEquip(FishingV2Manager.TYPE_BAIT,index)) as FarmAnimatedTextButton);
            }
            if(baitSlot.craft_bt)
            {
               this.m_baitCraftingButtons.push(new FarmAnimatedTextButton(baitSlot.craft_bt,"Craft",this.craftBait(index)) as FarmAnimatedTextButton);
            }
            if(baitSlot.craft_bt)
            {
               this.m_baitsBtArray[index] = new ZwFrame(baitSlot.craft_bt) as ZwFrame;
               this.m_baitsBtArray[index].attachTooltip(new FarmTextTooltip(""));
            }
            if(baitSlot.highlight_mc)
            {
               this.m_baitHighlightMCs.push(baitSlot.highlight_mc);
               this.m_baitHighlightMCs[index].visible = false;
            }
            if(baitSlot.rod_count_tf)
            {
               this.m_baitCountTFs.push(new ZwTextField(baitSlot.rod_count_tf,"") as ZwTextField);
            }
            if(baitSlot.craft_mc)
            {
               this.m_baitCraftMCs.push(baitSlot.craft_mc as MovieClip);
            }
            if(baitSlot.hasOwnProperty("fish_icon_mc"))
            {
               this.m_baitsArray[index] = new ZwFrame(baitSlot["fish_icon_mc"]) as ZwFrame;
               this.m_baitsArray[index].visible = true;
               if(index == 0)
               {
                  this.m_baitsArray[index].attachTooltip(this.m_worldRewardTooltip[index] = new FarmTextTooltip("Increase your chance of reeling in a fish by 2 times!")) as FarmTextTooltip;
               }
               else if(index == 1)
               {
                  this.m_baitsArray[index].attachTooltip(this.m_worldRewardTooltip[index] = new FarmTextTooltip("Increase your chance of reeling in a fish by 2 times!")) as FarmTextTooltip;
               }
               else
               {
                  this.m_baitsArray[index].attachTooltip(this.m_worldRewardTooltip[index] = new FarmTextTooltip("Increase your chance of reeling in a fish by 3 times!")) as FarmTextTooltip;
               }
            }
            if(baitSlot.craft_mc["skip_bt"])
            {
               this.m_baitSkipBTs.push(new FarmAnimatedCashButton(baitSlot.craft_mc.skip_bt,"Skip","",this.skipBaitCrafting(index)) as FarmAnimatedCashButton);
            }
            if(baitSlot.craft_mc["timer_tf"])
            {
               this.m_baitTimerTFs.push(new ZwTextField(baitSlot.craft_mc.timer_tf,"") as ZwTextField);
            }
            baitSlot.visible = true;
            index++;
         }
         baitsFrame.visible = true;
      }
      
      private function initRodsFrame() : void
      {
         var rodSlot:MovieClip = null;
         var rodsFrame:MovieClip = m_window["all_rod_mc"] as MovieClip;
         var index:int = 0;
         while(rodsFrame["rod_" + index.toString() + "_mc"])
         {
            rodSlot = rodsFrame["rod_" + index.toString() + "_mc"] as MovieClip;
            if(rodSlot.equip_bt)
            {
               this.m_rodEquipButtons.push(new FarmAnimatedTextButton(rodSlot.equip_bt,"",this.onSelectEquip(FishingV2Manager.TYPE_ROD,index)) as FarmAnimatedTextButton);
            }
            if(rodSlot.craft_bt)
            {
               this.m_rodCraftingButtons.push(new FarmAnimatedTextButton(rodSlot.craft_bt,"Craft",this.craftRod(index)) as FarmAnimatedTextButton);
            }
            if(rodSlot.craft_bt)
            {
               this.m_rodsBtArray[index] = new ZwFrame(rodSlot.craft_bt) as ZwFrame;
            }
            if(rodSlot.highlight_mc)
            {
               this.m_rodHighlightMCs.push(rodSlot.highlight_mc);
               this.m_rodHighlightMCs[index].visible = false;
            }
            if(rodSlot.rod_count_tf)
            {
               this.m_rodCountTFs.push(new ZwTextField(rodSlot.rod_count_tf,"") as ZwTextField);
            }
            if(rodSlot.craft_mc)
            {
               this.m_rodCraftMCs.push(rodSlot.craft_mc as MovieClip);
            }
            if(rodSlot.craft_mc["skip_bt"])
            {
               this.m_rodSkipBTs.push(new FarmAnimatedCashButton(rodSlot.craft_mc.skip_bt,"Skip","",this.skipRodCrafting(index)) as FarmAnimatedCashButton);
            }
            if(rodSlot.hasOwnProperty("fish_icon_mc"))
            {
               this.m_rodsArray[index] = new ZwFrame(rodSlot["fish_icon_mc"]) as ZwFrame;
               this.m_rodsArray[index].visible = true;
               if(index == 0)
               {
                  this.m_rodsArray[index].attachTooltip(this.m_rodsToolTip[index] = new FarmTextTooltip("Improves chance of getting a common fish!")) as FarmTextTooltip;
               }
               else if(index == 1)
               {
                  this.m_rodsArray[index].attachTooltip(this.m_rodsToolTip[index] = new FarmTextTooltip("Improves chance of getting an Uncommon fish!")) as FarmTextTooltip;
               }
               else
               {
                  this.m_rodsArray[index].attachTooltip(this.m_rodsToolTip[index] = new FarmTextTooltip("Improves chance of getting a Rare fish!")) as FarmTextTooltip;
               }
            }
            if(rodSlot.craft_mc["timer_tf"])
            {
               this.m_rodTimerTFs.push(new ZwTextField(rodSlot.craft_mc.timer_tf,"") as ZwTextField);
            }
            rodSlot.visible = true;
            index++;
         }
         rodsFrame.visible = true;
      }
      
      private function initBoostsFrame() : void
      {
         var boostSlot:MovieClip = null;
         var boostsFrame:MovieClip = m_window["all_boost_mc"] as MovieClip;
         var index:int = 0;
         while(boostsFrame["boost_" + index.toString() + "_mc"])
         {
            boostSlot = boostsFrame["boost_" + index.toString() + "_mc"] as MovieClip;
            if(boostSlot.buy_bt)
            {
               this.m_boostBuyButtons.push(new FarmAnimatedCashButton(boostSlot.buy_bt,"Buy","10",this.buyBoost(index)));
            }
            if(boostSlot.equip_bt)
            {
               this.m_boostEquipButtons.push(new FarmAnimatedTextButton(boostSlot.equip_bt,"",this.onSelectEquip(FishingV2Manager.TYPE_BOOST,index)) as FarmAnimatedTextButton);
            }
            if(boostSlot.highlight_mc)
            {
               this.m_boostHighlightMCs.push(boostSlot.highlight_mc);
               this.m_boostHighlightMCs[index].visible = false;
            }
            if(boostSlot.rod_count_tf)
            {
               this.m_boostCountTFs.push(new ZwTextField(boostSlot.rod_count_tf,"") as ZwTextField);
            }
            if(boostSlot.hasOwnProperty("fish_icon_mc"))
            {
               this.m_boostArray[index] = new ZwFrame(boostSlot["fish_icon_mc"]) as ZwFrame;
               this.m_boostArray[index].visible = true;
               if(index == 1)
               {
                  if(FishingV2Manager.getInstance().canApplySonarBooseter() == false)
                  {
                     this.m_boostArray[index].attachTooltip(new FarmTextTooltip("You have already mastered all rare fish"));
                  }
                  else
                  {
                     this.m_boostArray[index].attachTooltip(new FarmTextTooltip("Get Rare Type Fish only when this is equipped!"));
                  }
               }
            }
            boostSlot.visible = true;
            if(index == 0)
            {
               boostSlot.visible = false;
            }
            index++;
         }
         boostsFrame.visible = true;
      }
      
      private function get manager() : FishingV2Manager
      {
         return FishingV2Manager.getInstance(this.m_featureName);
      }
      
      private function refreshBaitsFrame() : void
      {
         var i:int = 0;
         var toolTipText:String = null;
         var key:String = null;
         var count:int = 0;
         var cost:int = 0;
         var hasStartedCrafting:Boolean = false;
         var isCrafting:Boolean = false;
         var itemType:int = FishingV2Manager.TYPE_BAIT;
         var anythingInCraftState:Boolean = false;
         for(i = 0; i < FishingV2Manager.ITEM_SUBTYPES.length; i++)
         {
            key = FishingV2Manager.BAITS_COUNT_KEYS[i];
            if(this.manager.canCollect(itemType,i))
            {
               this.manager.collectItem(itemType,i,key,1);
            }
            count = this.manager.getCountForKey(key);
            cost = int(FishingV2Manager.PRICES_BAITS[i]);
            hasStartedCrafting = this.manager.hasStartedCrafting(itemType,i);
            if(hasStartedCrafting)
            {
               anythingInCraftState = true;
            }
            this.m_baitEquipButtons[i].enabled = count > 0;
            this.m_baitEquipButtons[i].text = FishingV2Manager.m_selectedBait != i ? "Equip" : "Equipped";
            this.m_baitHighlightMCs[i].visible = FishingV2Manager.m_selectedBait == i;
            this.m_baitSkipBTs[i].setAmountText(cost.toString());
            this.m_baitCraftMCs[i].visible = hasStartedCrafting;
            this.m_baitSkipBTs[i].visible = hasStartedCrafting;
            this.m_baitCraftingButtons[i].visible = !hasStartedCrafting;
            this.m_baitCraftingButtons[i].enabled = this.manager.isCraftingAllowedForItem(itemType,i);
            this.m_baitCountTFs[i].text = "x" + count.toString();
            this.m_baitTimerTFs[i].text = "Ready In\n" + this.manager.getTimeLeft(itemType,i,true);
         }
         for(i = 0; i < 3; i++)
         {
            if(anythingInCraftState)
            {
               isCrafting = this.manager.hasStartedCrafting(itemType,i);
               if(isCrafting)
               {
                  if(i == 0)
                  {
                     toolTipText = "Get the fishes hooked!";
                  }
                  else if(i == 1)
                  {
                     toolTipText = "Increase your chance of reeling in a fish by 2 times";
                  }
                  else
                  {
                     toolTipText = "Increase your chance of reeling in a fish by 3 times";
                  }
               }
               else
               {
                  toolTipText = "Another Bait is getting crafted";
               }
            }
            else if(i == 0)
            {
               toolTipText = "Get the fishes hooked!";
            }
            else if(i == 1)
            {
               toolTipText = "Increase your chance of reeling in a fish by 2 times";
            }
            else
            {
               toolTipText = "Increase your chance of reeling in a fish by 3 times";
            }
            this.m_worldRewardTooltip[i].setText(toolTipText);
         }
      }
      
      private function refreshRodsFrame() : void
      {
         var i:int = 0;
         var toolTipText:String = null;
         var key:String = null;
         var count:int = 0;
         var cost:int = 0;
         var hasStartedCrafting:Boolean = false;
         var isCrafting:Boolean = false;
         var itemType:int = FishingV2Manager.TYPE_ROD;
         var anythingInCraftState:Boolean = false;
         for(i = 0; i < FishingV2Manager.ITEM_SUBTYPES.length; i++)
         {
            key = FishingV2Manager.RODS_COUNT_KEYS[i];
            if(this.manager.canCollect(itemType,i))
            {
               this.manager.collectItem(itemType,i,key,1);
            }
            count = this.manager.getCountForKey(key);
            cost = int(FishingV2Manager.PRICES_RODS[i]);
            hasStartedCrafting = this.manager.hasStartedCrafting(itemType,i);
            if(hasStartedCrafting)
            {
               anythingInCraftState = true;
            }
            this.m_rodEquipButtons[i].enabled = count > 0;
            this.m_rodEquipButtons[i].text = FishingV2Manager.m_selectedRod != i ? "Equip" : "Equipped";
            this.m_rodHighlightMCs[i].visible = FishingV2Manager.m_selectedRod == i;
            this.m_rodSkipBTs[i].setAmountText(cost.toString());
            this.m_rodCraftMCs[i].visible = hasStartedCrafting;
            this.m_rodSkipBTs[i].visible = hasStartedCrafting;
            this.m_rodCraftingButtons[i].visible = !hasStartedCrafting;
            this.m_rodCraftingButtons[i].enabled = this.manager.isCraftingAllowedForItem(itemType,i);
            this.m_rodCountTFs[i].text = "x" + count.toString();
            this.m_rodTimerTFs[i].text = "Ready In\n" + this.manager.getTimeLeft(itemType,i,true);
         }
         for(i = 0; i < 3; i++)
         {
            if(anythingInCraftState)
            {
               isCrafting = this.manager.hasStartedCrafting(itemType,i);
               if(isCrafting)
               {
                  toolTipText = "Improves chance of getting a " + FISH_TYPE[i] + " fish";
               }
               else
               {
                  toolTipText = "Another Rod is getting crafted";
               }
            }
            else
            {
               toolTipText = "Improves chance of getting a " + FISH_TYPE[i] + " fish";
            }
            this.m_rodsToolTip[i].setText(toolTipText);
         }
      }
      
      private function refreshBoostsFrame() : void
      {
         var count:int = 0;
         for(var i:int = 0; i < 2; i++)
         {
            count = this.manager.getCountForKey(FishingV2Manager.BOOSTS_COUNT_KEYS[i]);
            this.m_boostCountTFs[i].text = "x" + count.toString();
            this.m_boostEquipButtons[i].enabled = count > 0;
            this.m_boostEquipButtons[i].text = FishingV2Manager.m_selectedBoost != i ? "Equip" : "Unequip";
            this.m_boostHighlightMCs[i].visible = FishingV2Manager.m_selectedBoost == i;
            if(FishingV2Manager.getInstance().canApplySonarBooseter() == false && i == 1)
            {
               this.m_boostEquipButtons[1].enabled = false;
               this.m_boostEquipButtons[1].attachTooltip(new FarmTextTooltip("You have already mastered all rare fish"));
               this.m_boostBuyButtons[1].visible = false;
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.refreshRodsFrame();
         this.refreshBaitsFrame();
         this.refreshBoostsFrame();
         this.m_bootCountTF.text = "x" + FishingV2Manager.getInstance().getBootCount().toString();
         this.m_bootRedeemBT.enabled = FishingV2Manager.getInstance().canRedeemBoots();
         if(FishingV2Manager.m_selectedBait != -1 && FishingV2Manager.m_selectedRod != -1)
         {
            this.m_back_pulse_bt.visible = true;
         }
      }
      
      private function onTimerTick(event:Event) : void
      {
         this.refreshWindow();
      }
      
      public function onRedeemClick(e:Event) : void
      {
         FishingV2Manager.getInstance().redeemBoots();
         this.refreshWindow();
      }
      
      private function startTimer() : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimerTick);
            this.m_timer.start();
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimerTick);
            this.m_timer = null;
         }
      }
      
      override public function close() : void
      {
         this.stopTimer();
         if(FishingV2Manager.isTutorial2Over() == true)
         {
            this.manager.showMainUI();
         }
         super.close();
      }
      
      private function buyBoost(boostType:int) : Function
      {
         return function(event:Event):void
         {
            manager.buyBoost(boostType);
         };
      }
      
      private function onSelectEquip(equipmentType:int, index:int) : Function
      {
         return function(event:Event):void
         {
            switch(equipmentType)
            {
               case FishingV2Manager.TYPE_ROD:
                  FishingV2Manager.m_selectedRod = index;
                  break;
               case FishingV2Manager.TYPE_BAIT:
                  FishingV2Manager.m_selectedBait = index;
                  break;
               case FishingV2Manager.TYPE_BOOST:
                  FishingV2Manager.m_selectedBoost = FishingV2Manager.m_selectedBoost == index ? -1 : index;
            }
            refreshWindow();
            if(FishingV2Manager.isTutorial2Over() == false)
            {
               onOkay1Click(event);
            }
         };
      }
      
      private function skipBaitCrafting(index:int) : Function
      {
         return function(event:Event):void
         {
            manager.skipBaitCrafting(index);
         };
      }
      
      private function skipRodCrafting(index:int) : Function
      {
         return function(event:Event):void
         {
            manager.skipRodCrafting(index);
         };
      }
      
      private function craftBait(baitType:int) : Function
      {
         return function(event:Event):void
         {
            manager.startEquipmentCrafting(FishingV2Manager.TYPE_BAIT,baitType);
            refreshWindow();
         };
      }
      
      private function craftRod(index:int) : Function
      {
         return function(event:Event):void
         {
            manager.startEquipmentCrafting(FishingV2Manager.TYPE_ROD,index);
            refreshWindow();
         };
      }
      
      public function onOkay1Click(e:Event = null) : void
      {
         ++this.m_FTUEFrameNumber;
         switch(this.m_FTUEFrameNumber)
         {
            case 2:
               this.m_tutorial_mc.gotoAndStop(2);
               this.m_rodBt.visible = false;
               this.m_baitBt.visible = true;
               break;
            case 3:
               this.m_tutorial_mc.gotoAndStop(3);
               this.m_rodBt.visible = true;
               this.m_baitBt.visible = false;
               break;
            case 4:
               this.m_tutorial_mc.gotoAndStop(4);
               this.m_okay_bt1.visible = false;
               this.m_okay_bt2.visible = true;
               this.m_rodBt.visible = false;
               this.m_baitBt.visible = false;
               break;
            case 5:
               Global.player.setSeenFlag("FISHING_V2_TUTORIAL1");
               this.close();
               FishingV2Manager.getInstance().openMiniGame();
         }
      }
   }
}

