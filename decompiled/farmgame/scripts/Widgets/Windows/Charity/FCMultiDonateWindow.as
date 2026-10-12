package Widgets.Windows.Charity
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.MultiDonateManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.Charity.FCMultiDonateSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class FCMultiDonateWindow extends DonateWindow
   {
      
      private static const CAMPAIGN_PREFIX:String = "Campaign_";
      
      private static const LEGAL_URL:String = "http://zynga.org/campaigns/farmville-cause-choice/";
      
      private var m_legalFrame:ZwFrame;
      
      public function FCMultiDonateWindow(seedData:SeedItem = null, onAcceptCallback:Function = null, source:String = null, featureName:String = null)
      {
         super(seedData,onAcceptCallback,source,featureName);
         if(UI.isMarketWindowOpen())
         {
            UI.closeMarketDialog();
         }
      }
      
      protected function openLegal(event:MouseEvent) : void
      {
         if(!event.isRelatedObjectInaccessible)
         {
            navigateToURL(new URLRequest(LEGAL_URL),"_blank");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         m_mainFrame = addWidget(new ZwFrame(m_window.main_mc)) as ZwFrame;
         if(m_featureName != null && m_mainFrame != null && m_window != null && m_window.main_mc != null && m_window.main_mc.body0_tf != null && m_window.main_mc.legal_mc != null && m_window.main_mc.legal_mc.body1_tf != null && m_window.main_mc.slots_mc != null)
         {
            m_mainFrame.addWidget(new ZwTextField(m_window.main_mc.body0_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,CAMPAIGN_PREFIX + m_featureName + "_body")));
            this.m_legalFrame = m_mainFrame.addWidget(new ZwFrame(m_window.main_mc.legal_mc)) as ZwFrame;
            if(this.m_legalFrame != null)
            {
               this.m_legalFrame.registerEventListener(MouseEvent.CLICK,this.openLegal);
               (this.m_legalFrame.element as MovieClip).mouseChildren = false;
               (this.m_legalFrame.element as MovieClip).buttonMode = true;
               this.m_legalFrame.addWidget(new ZwTextField(m_window.main_mc.legal_mc.body1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,CAMPAIGN_PREFIX + m_featureName + "_legal")));
            }
            m_mainFrame.addWidget(new GenericSlotContainerFrame(m_window.main_mc.slots_mc,FCMultiDonateSlot,this.setupData(),this));
         }
         else
         {
            GlobalEngine.info("Campaign","No featurename and exports in FCMultiDonateWindow.");
         }
      }
      
      private function setupData() : Array
      {
         var itemInfo:Object = null;
         var slotsArray:Array = [];
         var mdmInstance:MultiDonateManager = MultiDonateManager.getInstance(m_featureName);
         var slotsNum:int = int(mdmInstance.rewardItemNames.length);
         var rewardItemNames:Array = mdmInstance.rewardItemNames;
         var rewardItemCosts:Array = mdmInstance.rewardItemCosts;
         var charityNames:Array = mdmInstance.charityNames;
         for(var itemCount:int = 0; itemCount < slotsNum; itemCount++)
         {
            itemInfo = {};
            itemInfo.isBonus = false;
            itemInfo.slotNum = itemCount;
            itemInfo.itemName = rewardItemNames[itemCount];
            itemInfo.itemCost = rewardItemCosts[itemCount];
            itemInfo.charityName = charityNames[itemCount];
            itemInfo.featureName = m_featureName;
            itemInfo.claimed = mdmInstance.isClaimed(itemInfo.itemName);
            slotsArray.push(itemInfo);
         }
         var bonusInfo:Object = {};
         bonusInfo.isBonus = true;
         bonusInfo.slotNum = rewardItemNames.length;
         bonusInfo.itemName = mdmInstance.bonusItemName;
         bonusInfo.featureName = m_featureName;
         bonusInfo.claimed = mdmInstance.isClaimed(bonusInfo.itemName);
         slotsArray.push(bonusInfo);
         return slotsArray;
      }
      
      override protected function release() : void
      {
         this.m_legalFrame = null;
         super.release();
      }
   }
}

