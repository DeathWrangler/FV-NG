package Display.HUD.HUDWidgets
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FeatureConfigManager;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FishingDerby.FishingDerbyStoreWindow;
   import Widgets.Windows.FishingDerby.TackleBoxWindow;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class HUDFishingDerbyWidget extends HUDWidget
   {
      
      public static const TACKLE_BOX_CLOSE:String = "tacklebox_rollover";
      
      private static const ASSET_PATH:String = "assets/hud/FV_TackleBoxHUD2.swf";
      
      private static const TOOLTIP_SHOW_FRAME_NUM:int = 30;
      
      private var m_fishingButton:FarmAnimatedTextButton;
      
      private var m_rodIcon:FarmIcon;
      
      private var m_rodText:ZwTextField;
      
      private var m_baitsCount:ZwTextField;
      
      private var m_baitIcon:FarmIcon;
      
      private var m_baitText:ZwTextField;
      
      private var m_buffText:ZwTextField;
      
      private var m_baitProgressBar:FarmProgressBar;
      
      private var m_lastTimestamp:Number = -1;
      
      private var m_replenishRate:Number;
      
      private var m_featureConfig:FeatureConfigManager;
      
      private var m_activeRod:String;
      
      private var m_activeBait:String;
      
      private var m_activeBuff:String;
      
      private var m_fishFinderIcon:FarmIcon;
      
      private var m_upArrow:ZwBaseWidget;
      
      private var m_downArrow:ZwBaseWidget;
      
      private var m_buffAction:FarmAnimatedTextButton;
      
      public function HUDFishingDerbyWidget(parentElement:Sprite)
      {
         super(ASSET_PATH,parentElement);
      }
      
      private static function openBuffWindow(event:Event) : void
      {
         var baitShopArray:Array = Global.world.getObjectsByCode("1lB");
         if(baitShopArray.length > 0)
         {
            UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_BUFF),true,"FishingDerbyStoreWindow",true);
         }
      }
      
      private static function openTackleBoxInventory(event:Event) : void
      {
         UI.displayPopup(new TackleBoxWindow(),true,"TackleBox",true);
      }
      
      private static function openTackleBoxToBuff(event:Event) : void
      {
         UI.displayPopup(new TackleBoxWindow(TackleBoxWindow.TAB_EXTRAS),true,"TackleBox",true);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var parentFrame:ZwFrame;
         var currentInventory:Object;
         var fishFinder:FarmItem;
         super.onLoadComplete(event);
         m_loader.y = 120;
         Global.hud.conditionallyRefreshHUD(true);
         this.m_featureConfig = FeatureConfigManager.getFeatureConfiguration(FishingDerbyManager.FEATURE_NAME);
         this.m_replenishRate = this.m_featureConfig.getNumberConstant("replenishRate");
         parentFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty("hitbox_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.hitbox_mc));
         }
         addWidget(new ZwTextField(m_element.title_tf,ZLocUtils.t_pk("Dialogs","TackleBoxHUD_Title")));
         addWidget(this.m_baitsCount = new ZwTextField(m_element.count_tf));
         addWidget(this.m_baitIcon = new FarmIcon(m_element.baits_icon));
         addWidget(this.m_baitText = new ZwTextField(m_element.bait_tf));
         addWidget(this.m_baitProgressBar = new FarmProgressBar(m_element.masteryInfo));
         addWidget(new FarmAnimatedTextButton(m_element.addBaits_mc,"",function(event:Event):void
         {
            var baitShopArray:* = Global.world.getObjectsByCode("1lB");
            if(baitShopArray.length > 0)
            {
               UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_BAITS),true,"FishingDerbyStoreWindow",true);
            }
         }));
         this.m_baitIcon.setIconSize(50,50);
         this.updateBaits();
         currentInventory = FishingDerbyManager.getFishingInventory();
         addWidget(this.m_upArrow = new ZwBaseWidget(m_element.hudUp_bt),false);
         addWidget(this.m_downArrow = new ZwBaseWidget(m_element.hudDown_bt),true);
         addWidget(this.m_rodIcon = new FarmIcon(m_element.subCard_mc.fishingRod_mc));
         addWidget(this.m_rodText = new ZwTextField(m_element.subCard_mc.rod_tf));
         addWidget(new FarmAnimatedTextButton(m_element.subCard_mc.change_bt,ZLocUtils.t_pk("Dialogs","TackleBoxHUD_ChangeRod"),function(event:Event):void
         {
            UI.displayPopup(new TackleBoxWindow(),true,"TackleBoxWindow",true);
         }));
         addWidget(new FarmAnimatedTextButton(m_element.subCard_mc.bait_bt,ZLocUtils.t_pk("Dialogs","TackleBoxHUD_BuyBait"),function(event:Event):void
         {
            var baitShopArray:* = Global.world.getObjectsByCode("1lB");
            if(baitShopArray.length > 0)
            {
               UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_BAITS),true,"FishingDerbyStoreWindow",true);
            }
         }));
         this.activeRod = currentInventory[FishingDerbyManager.INVENTORY_ROD];
         this.m_rodIcon.setIconSize(50,50);
         fishFinder = Global.farmGameSettingsManager.getFarmItemByName("fishfinder");
         addWidget(this.m_fishFinderIcon = new FarmIcon(m_element.subCard_mc.fishFinder_mc));
         this.m_fishFinderIcon.loadIcon(fishFinder.icon);
         this.m_fishFinderIcon.setIconSize(50,50);
         addWidget(this.m_buffText = new ZwTextField(m_element.subCard_mc.buff_tf));
         this.updateBuffs();
         addWidget(new FarmAnimatedTextButton(m_element.subCard_mc.inventory_bt,ZLocUtils.t_pk("Dialogs","TackleBoxHUD_InventoryBtn"),openTackleBoxInventory));
      }
      
      public function updateBuffs() : void
      {
         var buffs:Object = FishingDerbyManager.getFishingBuffs();
         this.activeBuff = buffs["active"];
         var buffsLeft:int = 0;
         if(buffs["buffs"].hasOwnProperty(this.activeBuff))
         {
            buffsLeft = int(buffs["buffs"][this.activeBuff]);
         }
         if(buffsLeft > 0)
         {
            if(!this.m_buffAction)
            {
               addWidget(this.m_buffAction = new FarmAnimatedTextButton(m_element.subCard_mc.buy_bt,ZLocUtils.t_pk("Dialogs","Unequip"),openTackleBoxInventory));
            }
         }
         else if(!this.m_buffAction)
         {
            addWidget(this.m_buffAction = new FarmAnimatedTextButton(m_element.subCard_mc.buy_bt,ZLocUtils.t_pk("Dialogs","BuyParts"),openBuffWindow));
         }
         if(buffs["active"] == "fishfinder" && buffsLeft > 0)
         {
            this.m_buffAction.text = ZLocUtils.t_pk("Dialogs","Unequip");
            this.m_buffAction.callback = openTackleBoxToBuff;
         }
         else if(buffs["active"] == "none" && buffs["buffs"]["fishfinder"] > 0)
         {
            this.m_buffAction.text = ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Equip");
            this.m_buffAction.callback = openTackleBoxToBuff;
         }
         else
         {
            this.m_buffAction.text = ZLocUtils.t_pk("Dialogs","BuyParts");
            this.m_buffAction.callback = openBuffWindow;
         }
      }
      
      public function set activeBait(newBait:String) : void
      {
         var farmItem:FarmItem = null;
         if(newBait != this.m_activeBait)
         {
            this.m_activeBait = newBait;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(newBait);
            if(farmItem != null)
            {
               this.m_baitIcon.loadIcon(farmItem.icon);
            }
            this.m_baitText.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         }
      }
      
      public function set activeBuff(newBuff:String) : void
      {
         var bufftext:String = null;
         var farmItem:FarmItem = null;
         if(newBuff != this.m_activeBuff)
         {
            this.m_activeBuff = newBuff;
            bufftext = "Fish Finder";
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(newBuff);
            if(farmItem != null)
            {
               this.m_fishFinderIcon.loadIcon(farmItem.icon);
               bufftext = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
            }
            this.m_buffText.text = bufftext;
         }
      }
      
      public function get activeBuff() : String
      {
         return this.m_activeBuff;
      }
      
      public function get activeBait() : String
      {
         return this.m_activeBait;
      }
      
      public function set activeRod(newRod:String) : void
      {
         var farmItem:FarmItem = null;
         if(newRod != this.m_activeRod)
         {
            this.m_activeRod = newRod;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(newRod);
            if(farmItem != null)
            {
               this.m_rodIcon.loadIcon(farmItem.icon);
            }
            this.m_rodText.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         }
      }
      
      public function get activeRod() : String
      {
         return this.m_activeRod;
      }
      
      private function showRollover() : void
      {
         this.updateBaits();
         this.m_upArrow.visible = true;
         this.m_downArrow.visible = false;
      }
      
      private function hideRollover() : void
      {
         this.m_upArrow.visible = false;
         this.m_downArrow.visible = true;
         Global.world.dispatchEvent(new Event(TACKLE_BOX_CLOSE));
      }
      
      public function updateBaits() : void
      {
         var timeDelta:Number = NaN;
         var timeLeft:Number = NaN;
         var maxNewBaits:Number = NaN;
         var newBaits:int = 0;
         var tooltipMessage:String = null;
         var fishingBaits:Object = FishingDerbyManager.getFishingBaits();
         var baitCount:int = int(fishingBaits["baits"][FishingDerbyManager.BAIT_WORM]);
         var maxBaits:int = this.m_featureConfig.getNumberConstant("maxDefaultBaits");
         this.activeBait = fishingBaits["active"];
         this.m_baitIcon.detachTooltip();
         if(fishingBaits != null && baitCount < maxBaits)
         {
            this.m_lastTimestamp = this.m_lastTimestamp != -1 ? this.m_lastTimestamp : Number(fishingBaits["ts"]);
            timeDelta = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_lastTimestamp;
            if(timeDelta > this.m_replenishRate)
            {
               maxNewBaits = maxBaits - baitCount;
               newBaits = Math.min(maxNewBaits,Math.round(timeDelta / this.m_replenishRate));
               fishingBaits["baits"][FishingDerbyManager.BAIT_WORM] += newBaits;
               if(fishingBaits["baits"][FishingDerbyManager.BAIT_WORM] >= maxBaits)
               {
                  this.m_lastTimestamp = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               }
               else
               {
                  this.m_lastTimestamp += newBaits * this.m_replenishRate;
               }
               fishingBaits["ts"] = this.m_lastTimestamp;
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FISHING_DERBY,FishingDerbyManager.FEATURE_BAIT,fishingBaits);
            }
            timeLeft = Math.floor(this.m_replenishRate - timeDelta);
            if(timeLeft > 0)
            {
               tooltipMessage = ZLocUtils.t_pk("Dialogs","FreeBait_textText",{"nextBaitTime":Math.floor(this.m_replenishRate - timeDelta)});
               if(fishingBaits["active"] == FishingDerbyManager.BAIT_WORM)
               {
                  this.m_baitIcon.attachTooltip(new FarmTextTooltip(tooltipMessage));
               }
            }
         }
         this.m_baitsCount.text = "x" + fishingBaits["baits"][fishingBaits["active"]];
         this.m_baitProgressBar.progress = fishingBaits["baits"][fishingBaits["active"]] / maxBaits * 100;
      }
      
      public function setX(location:Number) : void
      {
         m_loader.x = location;
      }
   }
}

