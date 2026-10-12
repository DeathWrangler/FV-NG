package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.ImageLoader;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.Party.TeaPartyDialog;
   import Display.Quests.QuestProgressBar;
   import Display.StrokeTextField;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.ReturningUserExperienceManager;
   import Transactions.TMarkQuestAsViewed;
   import ZQuest.Init.QuestSettingsInit;
   import com.greensock.plugins.*;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class QuestQueuedIcon extends QueuedIconWithArrow
   {
      
      private static const DIALOG_NAME:String = "questProgress";
      
      public static const QUEST_OBJECT_IMPORT_NAME:String = "questObject";
      
      private var m_quest:FarmQuest = null;
      
      private var m_progressBar:QuestProgressBar = null;
      
      private var m_toolTipIcon:DisplayObject;
      
      private var m_toolTipTitle:String;
      
      private var m_toolTipTitleText:TextField;
      
      private var m_titleStrokeField:StrokeTextField;
      
      public function QuestQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         super.init();
         this.m_quest = extraData.quest;
         this.iconName = this.m_quest.name;
         this.category = this.m_quest.category;
         if((QuestSettingsInit.getInstance() as FarmQuestSettingsInit).questManagerQuestChainCacheContains(iconName))
         {
            ++this.priority;
         }
      }
      
      public function onAdd() : void
      {
         this.conditionallyAttachArrow();
         this.attachProgressBar();
      }
      
      public function onComplete() : void
      {
         this.removeQuestIcon();
      }
      
      public function onExpired() : void
      {
         this.removeQuestIcon();
      }
      
      public function playProgressBarAnimation() : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.playAnimation(this.m_quest.progressByTasks);
         }
      }
      
      override public function finishClick(parent:DynamicIconQueue) : void
      {
         super.finishClick(parent);
         if(this.m_quest.isNew == true)
         {
            TransactionManager.addTransaction(new TMarkQuestAsViewed(this.m_quest.name));
            this.m_quest.setAsSeen();
         }
         this.m_quest.questManagerProgress = false;
         var queuedDialogsShown:Boolean = FarmQuestManager.getInstance().pumpIconQuestCompletionQueue(this.m_quest.displayIcon);
         if(!queuedDialogsShown)
         {
            this.m_quest.showProgress();
         }
         FarmStatsManager.count("fv_quest",this.m_quest.name,"hud_click");
         if(this.m_quest.progressViewType == "TeaPartyDialog")
         {
            FarmStatsManager.count(TeaPartyDialog.STATS_COUNTER_NAME,"dialog","hud_icon_click");
         }
      }
      
      protected function shouldAttachNewArrow() : Boolean
      {
         return this.m_quest.isNew || FarmQuestManager.getInstance().getIconCompletedQuests(this.m_quest.displayIcon).length > 0;
      }
      
      public function conditionallyAttachArrow() : void
      {
         var questManagerIcon:QuestManagerQueuedIcon = null;
         if(FarmQuestManager.getInstance().isQuestExpiringSoon(this.m_quest) && this.m_quest.shouldShowTimeLeftHUDSurfacing())
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER) == Experiments.VARIANT_QUEST_MANAGER_ON)
            {
               if(!(QuestSettingsInit.getInstance() as FarmQuestSettingsInit).questManagerQuestChainCacheContains(this.quest.name))
               {
                  if(Global.hud.iconQueue.getIconByName(this.quest.name) == null)
                  {
                     questManagerIcon = Global.hud.iconQueue.getIconByName(QuestManagerQueuedIcon.QUEST_MANAGER_ICON_NAME) as QuestManagerQueuedIcon;
                     if(questManagerIcon)
                     {
                        questManagerIcon.attachExpiryArrow(this.m_quest.getArrowExpiryString());
                     }
                  }
                  else
                  {
                     this.attachArrow(ArrowType.ARROWEXPIRY);
                  }
               }
            }
            else
            {
               this.attachArrow(ArrowType.ARROWEXPIRY);
            }
         }
         else if(this.shouldAttachNewArrow() == true)
         {
            this.attachArrow(ArrowType.ARROWNEW);
         }
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         switch(arrowType)
         {
            case ArrowType.ARROWEXPIRY:
               setArrowText(this.m_quest.getArrowExpiryString());
               break;
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t("Dialogs","NewGoals"));
               break;
            case ArrowType.ARROWUPDATE:
               setArrowText(ZLocUtils.t("Dialogs","Progress"));
               break;
            case ArrowType.BONUSPARTS:
               setArrowText(ZLocUtils.t("Dialogs","Progress"));
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
      
      public function get quest() : FarmQuest
      {
         return this.m_quest;
      }
      
      private function attachProgressBar() : void
      {
         this.m_progressBar = new QuestProgressBar(-20,25,0.25,0.25);
         this.m_progressBar.addEventListener(QuestProgressBar.ANIMATION_COMPLETE_EVENT,this.animationComplete);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.showProgressBar);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.hideProgressBar);
         addChild(this.m_progressBar);
         this.playProgressBarAnimation();
      }
      
      private function animationComplete(event:Event) : void
      {
         this.hideProgressBar();
      }
      
      private function removeQuestIcon() : void
      {
         this.removeEventListener(MouseEvent.MOUSE_OVER,this.showProgressBar);
         this.removeEventListener(MouseEvent.MOUSE_OUT,this.hideProgressBar);
         Global.hud.iconQueue.removeIconByName(this.m_quest.name);
      }
      
      private function showProgressBar(event:Event = null) : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.showProgressBar();
         }
      }
      
      private function hideProgressBar(event:Event = null) : void
      {
         if(this.m_progressBar)
         {
            this.m_progressBar.hideProgressBarWithDelay();
         }
      }
      
      override protected function canShowArrow() : Boolean
      {
         var result:Boolean = false;
         if(!ReturningUserExperienceManager.shouldHideArrowFlyout())
         {
            result = super.canShowArrow();
         }
         return result;
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         var variant:int = 0;
         var resultQuest:FarmQuest = null;
         var reward:Object = null;
         var item:FarmItem = null;
         var imageLoader:ImageLoader = null;
         if(this.quest.mouseOverFeatureEnabled)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MOUSEOVER_TOOLTIP);
            resultQuest = null;
            if(variant == 3)
            {
               resultQuest = FarmQuestManager.getInstance().getLastQuestInList(this.quest);
            }
            else
            {
               resultQuest = this.quest;
            }
            if(resultQuest != null)
            {
               for each(reward in resultQuest.farmRewards)
               {
                  if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                     imageLoader = ImageLoader.getInstance(item.icon);
                     imageLoader.getContent(this.onItemIconLoaded);
                     break;
                  }
               }
               this.m_toolTipTitle = ZLocUtils.t("Quests",resultQuest.name + "_Title");
               if(this.m_titleStrokeField == null)
               {
                  this.m_titleStrokeField = new StrokeTextField(2105376,0.8);
                  this.m_titleStrokeField.multiline = true;
                  this.m_titleStrokeField.wordWrap = true;
                  this.m_titleStrokeField.width = m_toolTipWidth;
                  this.m_titleStrokeField.autoSize = TextFieldAutoSize.LEFT;
                  this.m_titleStrokeField.cacheAsBitmap = true;
               }
               this.m_titleStrokeField.defaultTextFormat = new TextFormat("Arial",14,16777215,true);
               this.m_titleStrokeField.toolTipText = this.m_toolTipTitle;
               this.m_toolTipTitleText = this.m_titleStrokeField;
               this.m_toolTipTitleText.text = this.m_toolTipTitle;
               if(variant == 3)
               {
                  extraData["iconTooltip"] = ZLocUtils.t("Dialogs","questHUD_icontooltip",{
                     "questStage":"final quest",
                     "item":ZLocUtils.tk_pk(item.friendlyName)
                  });
               }
               else
               {
                  extraData["iconTooltip"] = ZLocUtils.t("Dialogs","questHUD_icontooltip",{
                     "questStage":"current stage",
                     "item":ZLocUtils.tk_pk(item.friendlyName)
                  });
               }
            }
         }
         super.onRollOver(event);
         if(this.quest.mouseOverFeatureEnabled)
         {
            if(m_toolTipObj == null || m_toolTipObj.parent == null)
            {
               StatsManager.count("error","quest_optimization","mouseover");
            }
            else
            {
               StatsManager.count("success","quest_optimization","tooltip");
            }
         }
      }
      
      override protected function drawBG(spr:Sprite) : void
      {
         var padding:Number = NaN;
         var maxTextWidth:int = 0;
         var maxHeight:int = 0;
         var bgWidth:int = 0;
         var bgHeight:int = 0;
         var bitmapData:BitmapData = null;
         var titleBitmapData:BitmapData = null;
         var titleRect:Rectangle = null;
         var textBitmapData:BitmapData = null;
         var textRect:Rectangle = null;
         var iconBitmapData:BitmapData = null;
         var iconRect:Rectangle = null;
         var bitmap:Bitmap = null;
         if(this.quest.mouseOverFeatureEnabled)
         {
            padding = 2;
            spr.graphics.clear();
            while(spr.numChildren > 0)
            {
               spr.removeChildAt(0);
            }
            if(this.m_toolTipIcon == null)
            {
               this.m_toolTipIcon = new Sprite();
               (this.m_toolTipIcon as Sprite).graphics.beginFill(0,0);
               (this.m_toolTipIcon as Sprite).graphics.drawRect(0,0,80,60);
               (this.m_toolTipIcon as Sprite).graphics.endFill();
            }
            maxTextWidth = Math.max(this.m_toolTipTitleText.textWidth,m_toolTipText.textWidth);
            maxHeight = Math.max(2 * this.m_toolTipTitleText.textHeight + m_toolTipText.textHeight,this.m_toolTipIcon.height);
            bgWidth = maxTextWidth + this.m_toolTipIcon.width + padding * 8;
            bgHeight = maxHeight + padding * 7;
            bitmapData = new BitmapData(bgWidth,bgHeight,true,0);
            titleBitmapData = new BitmapData(this.m_toolTipTitleText.textWidth + padding,this.m_toolTipTitleText.textHeight + padding,true,0);
            titleBitmapData.draw(this.m_toolTipTitleText);
            titleRect = new Rectangle(0,0,this.m_toolTipTitleText.textWidth + padding,this.m_toolTipTitleText.textHeight + padding);
            bitmapData.copyPixels(titleBitmapData,titleRect,new Point(padding * 3,padding * 3));
            textBitmapData = new BitmapData(m_toolTipText.textWidth + padding,m_toolTipText.textHeight + padding,true,0);
            textBitmapData.draw(m_toolTipText);
            textRect = new Rectangle(0,0,m_toolTipText.textWidth + padding,m_toolTipText.textHeight + padding);
            bitmapData.copyPixels(textBitmapData,textRect,new Point(3 * padding,this.m_toolTipTitleText.textHeight * 2 + padding * 3));
            iconBitmapData = new BitmapData(this.m_toolTipIcon.width + padding * 2,this.m_toolTipIcon.height + padding,true,0);
            iconBitmapData.draw(this.m_toolTipIcon);
            iconRect = new Rectangle(0,0,this.m_toolTipIcon.width + padding * 2,this.m_toolTipIcon.height + padding);
            bitmapData.copyPixels(iconBitmapData,iconRect,new Point(maxTextWidth + padding * 6,padding * 3));
            bitmap = new Bitmap(bitmapData);
            spr.addChild(bitmap);
            spr.graphics.beginFill(0,0.4);
            spr.graphics.drawRoundRect(0,0,bgWidth,bgHeight,8,8);
            spr.graphics.endFill();
         }
         else
         {
            super.drawBG(spr);
         }
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         this.m_toolTipTitleText = null;
         if(this.m_toolTipIcon != null)
         {
            this.m_toolTipIcon.filters = null;
         }
         this.m_toolTipIcon = null;
      }
      
      private function onItemIconLoaded(content:DisplayObject) : void
      {
         this.m_toolTipIcon = content as DisplayObject;
         if(this.m_toolTipIcon != null)
         {
            this.m_toolTipIcon.filters = [new GlowFilter(16777215,1,5,5,10)];
         }
      }
   }
}

