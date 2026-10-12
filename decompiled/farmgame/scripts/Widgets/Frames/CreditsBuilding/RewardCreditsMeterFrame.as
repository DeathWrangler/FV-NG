package Widgets.Frames.CreditsBuilding
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class RewardCreditsMeterFrame extends MeterFrame
   {
      
      private var m_levelTitles:Array = new Array();
      
      private var m_totalCredits:uint = 0;
      
      private var m_icon:FarmIcon = null;
      
      private var m_titleTextField:ZwTextField;
      
      public function RewardCreditsMeterFrame(element:DisplayObject, building:RewardCreditsBuilding, featureName:String)
      {
         super(element,building,featureName,true);
         this.populateLevelTitles();
         if(m_element.status_tf)
         {
            addWidget(new ZwTextField(m_element.status_tf,this.getLevelTitle(m_building.getTotalCreditsReceived())));
         }
         m_progressBar.maximum = int(Global.farmGameSettingsManager.getBuildingCreditsXml(featureName).@meterMaxCredits);
         this.m_totalCredits = m_building.getTotalCreditsReceived();
         m_progressBar.animated = true;
         this.refreshMeter();
         if(m_element.meterItem0_mc)
         {
            (m_element.meterItem0_mc as MovieClip).visible = true;
            this.toggleStateVisibility(0,false);
         }
      }
      
      private function populateLevelTitles() : void
      {
         var strPK:String = null;
         var totalLevels:int = m_building.getNumTotalLevels() - 1;
         for(var index:uint = 0; index < totalLevels; index++)
         {
            strPK = RewardCreditsBuilding.getLocalizedKey(m_featureName,"Level_" + (index + 1));
            this.m_levelTitles[index] = "" != strPK ? ZLocUtils.tk_pk_asTitle(strPK) : "";
         }
      }
      
      private function setupStateIcons() : void
      {
         var totalLevels:int = m_building.getNumTotalLevels() - 1;
         var level:int = m_building.getLevel();
         var showStages:Boolean = Global.farmGameSettingsManager.getShowBasketStages(this.m_featureName);
         var index:uint = 0;
         while(index < totalLevels && Boolean(m_element["meterItem" + (index + 1) + "_mc"]))
         {
            (m_element["meterItem" + (index + 1) + "_mc"] as MovieClip).visible = true;
            if(index < level || showStages)
            {
               this.toggleStateVisibility(index + 1,false);
            }
            else
            {
               this.toggleStateVisibility(index + 1,true);
            }
            index++;
         }
      }
      
      private function toggleStateVisibility(index:uint, locked:Boolean) : void
      {
         if(getWidget(m_element["meterItem" + index + "_mc"]) != null)
         {
            removeWidget(m_element["meterItem" + index + "_mc"]);
         }
         var parentFrame:ZwFrame = addWidget(new ZwFrame(m_element["meterItem" + index + "_mc"])) as ZwFrame;
         if(locked)
         {
            parentFrame.element.lock_mc.visible = true;
         }
         else
         {
            parentFrame.element.lock_mc.visible = false;
            this.m_icon = new FarmIcon(parentFrame.element.Item,"assets/decorations/deco_" + m_featureName + "_" + index + "_icon.png");
            this.m_icon.setIconSize(50,50);
            parentFrame.addWidget(this.m_icon,true);
         }
      }
      
      private function getLevelTitle(numCreditsReceived:uint) : String
      {
         var strPK:String = null;
         var title:String = "";
         var levels:Array = m_building.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            if(numCreditsReceived >= levels[index])
            {
               title = this.m_levelTitles[index];
            }
         }
         if(!title)
         {
            strPK = RewardCreditsBuilding.getLocalizedKey(m_featureName,"Level_0");
            title = "" != strPK ? ZLocUtils.tk_pk_asTitle(strPK) : "";
         }
         return title;
      }
      
      override protected function getProgressBarContainer() : DisplayObject
      {
         return m_element.stack_mc;
      }
      
      override protected function getIncrementPrefixTextFieldContainer() : String
      {
         return "increment";
      }
      
      public function get animated() : Boolean
      {
         return m_progressBar.animated;
      }
      
      public function set animated(value:Boolean) : void
      {
         m_progressBar.animated = value;
      }
      
      override public function refreshMeter() : void
      {
         super.refreshMeter();
         (getWidget(m_element.receivedAmount_tf) as ZwTextField).text = m_building.getTotalCreditsReceived().toString();
         if(m_element.status_tf)
         {
            (getWidget(m_element.status_tf) as ZwTextField).text = this.getLevelTitle(m_building.getTotalCreditsReceived()).toString();
         }
         if(m_element.meterItem0_mc)
         {
            this.setupStateIcons();
         }
      }
      
      override protected function addCounterText() : void
      {
         var strPK:String = RewardCreditsBuilding.getLocalizedKey(m_featureName,"TotalCreditsReceivedLabel");
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(m_featureName);
         var str:String = "";
         if("" != strPK)
         {
            if("" != itemPK && ZLocUtils.isObject(itemPK))
            {
               str = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
            }
            else
            {
               str = ZLocUtils.t_pk(strPK);
            }
         }
         if(m_element.receivedLabel_tf)
         {
            addWidget(new ZwTextField(m_element.receivedLabel_tf,str));
         }
         var totalCreditsReceived:int = int(m_building.getTotalCreditsReceived());
         addWidget(new ZwTextField(m_element.receivedAmount_tf,totalCreditsReceived.toString()));
      }
      
      override protected function buildMeterBarTickMarks() : void
      {
         var index:int = 0;
         var level:uint = 0;
         var nextText:TextField = null;
         var levels:Array = m_building.getLevelCredits();
         var element:TextField = this.getProgressBarContainer()[this.getIncrementPrefixTextFieldContainer() + "0_tf"];
         if(element != null)
         {
            addWidget(new ZwTextField(this.getProgressBarContainer()[this.getIncrementPrefixTextFieldContainer() + "0_tf"],"0"));
            for(index = 0; index < m_building.stateChangeLevels.length; index++)
            {
               level = uint(m_building.stateChangeLevels[index]);
               nextText = this.getProgressBarContainer()[this.getIncrementPrefixTextFieldContainer() + (index + 1) + "_tf"];
               if(nextText)
               {
                  addWidget(new ZwTextField(nextText,levels[level]));
               }
            }
         }
      }
   }
}

