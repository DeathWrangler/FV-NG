package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.SlotMachineFManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SlotMachine.SlotMachineCompleteFrame;
   import Widgets.Frames.SlotMachine.SlotMachineProgressFrame;
   import Widgets.Frames.SlotMachineSlotContainerFrame;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class SlotMachineWindow extends FarmWindow
   {
      
      private static const THROW_TOKEN_ANIM_IN_HAND_FRAME:Number = 11;
      
      private static const THROW_TOKEN_ANIM_EMPTY_HAND_FRAME:Number = 0;
      
      protected var m_building:FeatureBuilding;
      
      protected var m_level:ZwTextField;
      
      protected var m_completeFrame:SlotMachineCompleteFrame;
      
      protected var m_progressFrame:SlotMachineProgressFrame;
      
      protected var m_collectionFrame:SlotMachineSlotContainerFrame;
      
      private var m_isPennyThrowAnimating:Boolean = false;
      
      private var m_isRewardFoundAnimating:Boolean = false;
      
      private var m_showWhatIsThisDialog:Boolean = false;
      
      protected var m_replayWidget:ZwWidget = null;
      
      public function SlotMachineWindow(building:FeatureBuilding, windowAssetRelUrl:String, showWhatIsThisDialog:Boolean = false)
      {
         super(windowAssetRelUrl);
         this.m_building = building;
         this.m_showWhatIsThisDialog = showWhatIsThisDialog;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_DialogTitle")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_TitleLvl")));
         this.m_level = addWidget(new ZwTextField(m_window.generic2_tf)) as ZwTextField;
         var whatisthisText:String = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_WhatIsThis_buttonText");
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,whatisthisText,this.displayWhatIsThis,true));
         this.m_completeFrame = addWidget(new SlotMachineCompleteFrame(m_window.completedFrame_mc,this.m_building),this.m_building.slotmachine.isComplete) as SlotMachineCompleteFrame;
         this.m_progressFrame = addWidget(new SlotMachineProgressFrame(m_window.inProgressFrame_mc,this.m_building),!this.m_building.slotmachine.isComplete) as SlotMachineProgressFrame;
         this.m_collectionFrame = addWidget(new SlotMachineSlotContainerFrame(m_window.collectionFrame_mc,this.m_building)) as SlotMachineSlotContainerFrame;
         this.m_replayWidget = addWidget(new FarmAnimatedTextButton(m_window.completedFrame_mc.replay_bt,"Replay",this.onReplay)) as ZwWidget;
         if(this.m_showWhatIsThisDialog)
         {
            this.displayWhatIsThis();
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         this.refresh();
         this.trackFirstUILoadOfTheDay();
      }
      
      private function trackFirstUILoadOfTheDay() : void
      {
         var featureFlag:String = null;
         var lastShown:Number = NaN;
         var featureFrequency:Number = NaN;
         var currentTime:int = 0;
         if(Boolean(this.m_building) && Boolean(this.m_building.slotmachine))
         {
            featureFlag = this.m_building.getItem().name + "_seen_dialog";
            lastShown = Global.player.getFeatureLastShown(featureFlag);
            featureFrequency = Global.farmGameSettingsManager.getNumber(this.m_building.getItem().name + "SeenDialogFeatureFrequency",86400);
            currentTime = GlobalEngine.serverTime / 1000;
            if(Boolean(this.m_building) && Boolean(this.m_building.slotmachine) && currentTime > lastShown + featureFrequency)
            {
               FarmStatsManager.count(this.m_building.getItem().name,"penny_count_on_UI_load",this.m_building.slotmachine.tokenCount.toString());
               Global.player.setFeatureLastShown(featureFlag,currentTime,true);
            }
         }
      }
      
      public function playAnimation(mc:MovieClip) : void
      {
         mc.visible = true;
         mc.gotoAndPlay(0);
      }
      
      public function playUseTokenAnim() : void
      {
         var mc:MovieClip = null;
         mc = m_window.penny_mc;
         mc.visible = true;
         this.m_isPennyThrowAnimating = true;
         this.m_isRewardFoundAnimating = true;
         mc.addEventListener(Event.ENTER_FRAME,function(e:Event):void
         {
            if(mc.currentFrame == mc.totalFrames)
            {
               mc.removeEventListener(e.type,arguments.callee);
               m_isPennyThrowAnimating = false;
               refreshTokenInHand();
               refresh();
            }
         });
         mc.visible = true;
         mc.play();
      }
      
      public function refreshTokenInHand() : void
      {
         var mc:MovieClip = null;
         if(Boolean(!this.m_isPennyThrowAnimating && m_window && m_window.penny_mc) && Boolean(this.m_building) && Boolean(this.m_building.slotmachine))
         {
            mc = m_window.penny_mc;
            if(mc)
            {
               if(this.m_building.slotmachine.tokenCount > 0)
               {
                  if(mc.currentFrame != THROW_TOKEN_ANIM_IN_HAND_FRAME)
                  {
                     mc.visible = true;
                     mc.gotoAndStop(THROW_TOKEN_ANIM_IN_HAND_FRAME);
                  }
               }
               else if(mc.currentFrame != THROW_TOKEN_ANIM_EMPTY_HAND_FRAME)
               {
                  mc.visible = true;
                  mc.gotoAndStop(THROW_TOKEN_ANIM_EMPTY_HAND_FRAME);
               }
            }
         }
      }
      
      public function playXPFoundAnim(xpAmount:Number) : void
      {
         var mc:MovieClip = m_window.xpRewardWell_mc;
         mc.visible = true;
         mc.gotoAndStop(2);
         mc.xpReward_mc.generic_tf.text = String(xpAmount);
         mc.play();
      }
      
      public function playBonusRewardAnim(rewardImageUrl:String) : void
      {
         var mc:MovieClip = null;
         mc = m_window.bonusReward_mc;
         mc.visible = true;
         this.loadIcon(rewardImageUrl,mc.icon_mc);
         mc.addEventListener(Event.ENTER_FRAME,function(e:Event):void
         {
            if(mc.currentFrame == mc.totalFrames)
            {
               mc.gotoAndStop(0);
               mc.removeEventListener(e.type,arguments.callee);
               m_isRewardFoundAnimating = false;
               m_progressFrame.setButtonState(m_isPennyThrowAnimating,m_isRewardFoundAnimating);
            }
         });
         this.playAnimation(mc);
      }
      
      public function playXPFoundSlotAnim(slotNum:Number, xpAmount:Number) : void
      {
         var mc:MovieClip = null;
         if(slotNum >= 0 && slotNum < this.m_collectionFrame.totalSlots())
         {
            mc = m_window["xpRewardSlot_" + slotNum + "_mc"];
            mc.visible = true;
            mc.gotoAndStop(2);
            xpAmount = Global.player.calculateAndAddXp(xpAmount);
            mc.xpReward_mc.generic_tf.text = String(xpAmount);
            mc.play();
         }
      }
      
      public function playRewardFoundSlotAnim(slotNum:Number, rewardImageUrl:String, xpAmount:Number = 0) : void
      {
         var mc:MovieClip = null;
         if(slotNum >= 0 && slotNum < this.m_collectionFrame.totalSlots())
         {
            mc = m_window["rewardSlot_" + slotNum + "_mc"];
            mc.visible = true;
            this.loadIcon(rewardImageUrl,mc.rewardAnimation_mc.icon_mc);
            mc.rewardAnimation_mc.addEventListener(Event.ENTER_FRAME,function(e:Event):void
            {
               if(mc.rewardAnimation_mc.currentFrame == mc.rewardAnimation_mc.totalFrames)
               {
                  mc.rewardAnimation_mc.gotoAndStop(0);
                  mc.rewardAnimation_mc.removeEventListener(e.type,arguments.callee);
                  m_isRewardFoundAnimating = false;
                  m_progressFrame.setButtonState(m_isPennyThrowAnimating,m_isRewardFoundAnimating);
                  if(xpAmount > 0)
                  {
                     playXPFoundSlotAnim(slotNum,xpAmount);
                  }
                  m_collectionFrame.refreshCollectibleData();
               }
            });
            this.playAnimation(mc.rewardAnimation_mc);
         }
      }
      
      private function loadIcon(path:String, container:MovieClip, scale:Number = 0.5) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(Global.getAssetURL(path),function(event:Event):void
         {
            var dispObj:* = icon.content;
            dispObj.scaleX = dispObj.scaleY = scale;
            Utilities.removeAllChildren(container);
            container.addChild(dispObj);
            container.visible = true;
         });
      }
      
      public function scrollToCurrentTier() : void
      {
         if(this.m_collectionFrame)
         {
            this.m_collectionFrame.scrollToCurrentTier();
         }
      }
      
      override protected function release() : void
      {
         this.m_replayWidget = null;
         super.release();
      }
      
      override public function close() : void
      {
         if(Boolean(this.m_building) && Boolean(this.m_building.slotmachine))
         {
            this.m_building.slotmachine.onWindowClose();
         }
         super.close();
      }
      
      public function updateProgress() : void
      {
         if(this.m_progressFrame)
         {
            this.m_progressFrame.update(this.m_isPennyThrowAnimating,this.m_isRewardFoundAnimating);
         }
      }
      
      public function updateCollections(data:Array) : void
      {
         if(this.m_collectionFrame)
         {
            this.m_collectionFrame.update(data);
         }
      }
      
      public function refresh() : void
      {
         var currentLevelNumber:Number = NaN;
         var currentLevel:String = null;
         if(Boolean(this.m_building && this.m_building.slotmachine) && Boolean(m_shown) && m_window != null)
         {
            if(this.m_building.slotmachine.isComplete)
            {
               this.m_completeFrame.visible = true;
               this.m_progressFrame.visible = false;
            }
            else
            {
               this.m_completeFrame.visible = false;
               this.m_progressFrame.visible = true;
            }
            this.refreshTokenInHand();
            currentLevelNumber = this.m_building.slotmachine.levelCollections.length;
            currentLevel = this.m_building.slotmachine.currentLevel;
            if(currentLevel != SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE)
            {
               currentLevelNumber = Number(this.m_building.slotmachine.currentLevel) + 1;
            }
            this.m_level.text = this.m_building.slotmachine.currentTotalLevelDisplayString;
            this.updateProgress();
            this.updateCollections(this.m_building.slotmachine.lastCollectionCountersUpdate);
            this.updateAnimations();
         }
      }
      
      public function addDisplayPennyStatusText(delta:Number) : void
      {
         var message:String = null;
         if(delta > 0)
         {
            if(delta == 1)
            {
               message = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PennyStatusSingle",{"quantity":delta});
            }
            else
            {
               message = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_PennyStatusMulti",{"quantity":delta});
            }
            this.displayPennyStatus(message);
         }
      }
      
      public function displayPennyStatus(message:String, iconUrl:String = "", iconFilters:Array = null, tweenDuration:Number = 1.5, tweenDisplacement:int = 32, fontSize:int = 16, fontColor:uint = 16777215) : void
      {
         var localPos:Point = new Point(m_window.inProgressFrame_mc.pennyCount_mc.generic2_tf.x,m_window.inProgressFrame_mc.pennyCount_mc.generic2_tf.y - m_window.inProgressFrame_mc.pennyCount_mc.generic2_tf.height * 2);
         var screen:Point = m_window.inProgressFrame_mc.pennyCount_mc.generic2_tf.localToGlobal(localPos);
         UI.displayStatus(message,screen.x,screen.y,iconUrl,iconFilters,tweenDuration,tweenDisplacement,fontSize,fontColor);
      }
      
      private function updateAnimations() : void
      {
         var item:FarmItem = null;
         var lastTransactionResult:Object = null;
         var lastCollectionCountersUpdate:Array = null;
         var key:String = null;
         var obj:Object = null;
         var count:Number = NaN;
         var link:String = null;
         var xpGained:Number = NaN;
         var bonusItem:FarmItem = null;
         if(Boolean(this.m_building && this.m_building.slotmachine) && Boolean(this.m_collectionFrame) && !this.m_isPennyThrowAnimating)
         {
            item = null;
            lastTransactionResult = this.m_building.slotmachine.lastTransactionResult;
            lastCollectionCountersUpdate = this.m_building.slotmachine.lastCollectionCountersUpdate;
            if(lastCollectionCountersUpdate != null)
            {
               for(key in lastCollectionCountersUpdate)
               {
                  obj = lastCollectionCountersUpdate[key];
                  count = Number(obj.count);
                  link = obj.link;
                  item = Global.farmGameSettingsManager.getFarmItemByCode(key);
                  if(item != null)
                  {
                     xpGained = 0;
                     if(Boolean(count > 0 && lastTransactionResult && lastTransactionResult.hasOwnProperty("xpGain") && lastTransactionResult.xpGain) && Boolean(lastTransactionResult.hasOwnProperty("xpAnimationPlayed")) && !lastTransactionResult.xpAnimationPlayed)
                     {
                        xpGained = Number(lastTransactionResult.xpGain);
                        lastTransactionResult.xpAnimationPlayed = true;
                     }
                     this.playRewardFoundSlotAnim(this.m_collectionFrame.slotIndexOfItem(item),item.iconRelativeUrl,xpGained);
                  }
               }
               this.m_building.slotmachine.lastCollectionCountersUpdate = null;
            }
            if(lastTransactionResult != null)
            {
               if(lastTransactionResult.lootItemName != null && !lastTransactionResult.lootItemAnimationPlayed)
               {
                  bonusItem = Global.farmGameSettingsManager.getFarmItemByName(lastTransactionResult.lootItemName);
                  this.playBonusRewardAnim(bonusItem.iconRelativeUrl);
                  lastTransactionResult.lootItemAnimationPlayed = true;
               }
               this.m_building.slotmachine.lastTransactionResult = lastTransactionResult;
            }
         }
      }
      
      public function displayWhatIsThis(event:Event = null) : void
      {
         var imageSize:Number = 100;
         var message:String = ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_WhatIsThis");
         var howDoesThisWorkPopup:GenericXMLDialog = new GenericXMLDialog("","",null,null,imageSize,imageSize,message,null,false,"Accept",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(howDoesThisWorkPopup,false,"slotmachine_howDoesThisWorkPopup",true);
      }
      
      public function onReplay(event:Event) : void
      {
         Global.player.incrementActionCount(SlotMachineFManager.STRING_ALLCOLLECTIONSCOMPLETE);
         this.m_completeFrame.visible = false;
         this.m_progressFrame.visible = true;
         this.m_building.slotmachine.clearPrizes();
         this.m_collectionFrame.refreshCollectibleData(true);
         this.refresh();
      }
   }
}

