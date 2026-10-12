package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Managers.MiniDartsManager;
   import Widgets.Frames.ResourcePreviewFrame;
   import flash.events.MouseEvent;
   
   public class MinidartsWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static const OFFSET_OPF_Y:int = -20;
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      private const GIFT_MC:String = "gift_mc";
      
      private const ITEM_0_MC:String = "item_0_mc";
      
      private const ITEM_1_MC:String = "item_1_mc";
      
      private const ITEM_2_MC:String = "item_2_mc";
      
      private var m_icon:ResourcePreviewFrame;
      
      public function MinidartsWidgetMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardItem:FarmItem = null;
         var overrideExportName:String = null;
         var rewardItemState:String = null;
         super.postLoadComplete();
         if(m_window.mainWindow.hasOwnProperty([this.GIFT_MC]))
         {
            m_window.mainWindow[this.GIFT_MC].gotoAndPlay(1);
            rewardItemState = "static";
            if(m_window.mainWindow[this.GIFT_MC].hasOwnProperty([this.ITEM_0_MC]))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(MiniDartsManager.getInstance().getMotdItemByKey("PRIZES1"));
               if(rewardItem)
               {
                  addWidget(this.m_icon = new ResourcePreviewFrame(m_window.mainWindow[this.GIFT_MC][this.ITEM_0_MC]));
                  if(rewardItem.getImageByName("frt_idle") != null)
                  {
                     rewardItemState = "frt_idle";
                  }
                  overrideExportName = rewardItem.overrideExportName;
                  if(overrideExportName == "")
                  {
                     overrideExportName = rewardItem.name;
                  }
                  this.m_icon.visible = true;
                  this.m_icon.load(rewardItem.imageRelativeUrl(rewardItemState),overrideExportName + "_" + rewardItemState,null,true,false);
               }
            }
            if(m_window.mainWindow[this.GIFT_MC].hasOwnProperty([this.ITEM_1_MC]))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(MiniDartsManager.getInstance().getMotdItemByKey("PRIZES2"));
               if(rewardItem)
               {
                  addWidget(this.m_icon = new ResourcePreviewFrame(m_window.mainWindow[this.GIFT_MC][this.ITEM_1_MC]));
                  if(rewardItem.getImageByName("frt_idle") != null)
                  {
                     rewardItemState = "frt_idle";
                  }
                  overrideExportName = rewardItem.overrideExportName;
                  if(overrideExportName == "")
                  {
                     overrideExportName = rewardItem.name;
                  }
                  this.m_icon.visible = true;
                  this.m_icon.load(rewardItem.imageRelativeUrl(rewardItemState),overrideExportName + "_" + rewardItemState,null,true,false);
               }
            }
            if(m_window.mainWindow[this.GIFT_MC].hasOwnProperty([this.ITEM_2_MC]))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(MiniDartsManager.getInstance().getMotdItemByKey("PRIZES3"));
               if(rewardItem)
               {
                  addWidget(this.m_icon = new ResourcePreviewFrame(m_window.mainWindow[this.GIFT_MC][this.ITEM_2_MC]));
                  if(rewardItem.getImageByName("frt_idle") != null)
                  {
                     rewardItemState = "frt_idle";
                  }
                  overrideExportName = rewardItem.overrideExportName;
                  if(overrideExportName == "")
                  {
                     overrideExportName = rewardItem.name;
                  }
                  this.m_icon.visible = true;
                  this.m_icon.load(rewardItem.imageRelativeUrl(rewardItemState),overrideExportName + "_" + rewardItemState,null,true,false);
               }
            }
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         close();
         var actionParams:Object = null;
         if(currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS))
         {
            actionParams = currentMOTD[CUSTOM_ACTION_PARAMS];
         }
         MiniDartsManager.getInstance().openMiniDartUI();
      }
   }
}

