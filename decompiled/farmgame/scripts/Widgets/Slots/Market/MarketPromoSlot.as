package Widgets.Slots.Market
{
   import Classes.MarketPromotion;
   import Classes.StarterPack.StarterPackUtility;
   import Managers.MarketStatsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.Market.MarketPromoSlotFrame;
   import Widgets.Windows.Market.MarketPromoDynamicWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MarketPromoSlot extends ZwSlotFrame
   {
      
      private var m_container:MarketPromoSlotFrame;
      
      private var m_data:Array;
      
      private var m_data_index:int = 0;
      
      private var m_current_load_index:int = 0;
      
      private var m_externalPromoWindow:Array = null;
      
      public function MarketPromoSlot(element:DisplayObject, container:MarketPromoSlotFrame)
      {
         this.m_container = container;
         super(element);
         addWidget(new ZwFrame(m_element.loader_mc));
      }
      
      public function get data() : Array
      {
         return this.m_data;
      }
      
      public function get data_index() : int
      {
         return this.m_data_index;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as Array;
         var loaderMcZFrame:ZwFrame = getWidget(m_element.loader_mc) as ZwFrame;
         loaderMcZFrame.visible = true;
         if(!this.m_externalPromoWindow)
         {
            this.m_externalPromoWindow = new Array();
            this.m_current_load_index = this.m_data_index;
            this.createNextPromoDynamicWindow();
         }
      }
      
      private function createNextPromoDynamicWindow() : void
      {
         var promoData:MarketPromotion = null;
         var onPromoClickedCallback:Function = null;
         var promoDynamicWindow:MarketPromoDynamicWindow = null;
         var loaderMc:MovieClip = null;
         var loadIndex:int = this.m_current_load_index;
         loadIndex = loadIndex < this.m_data.length ? loadIndex : 0;
         if(Boolean(this.m_data) && this.m_externalPromoWindow[loadIndex] == null)
         {
            promoData = this.m_data[loadIndex] as MarketPromotion;
            if(promoData)
            {
               onPromoClickedCallback = this.m_container.promoClickCallback;
               promoDynamicWindow = new MarketPromoDynamicWindow(promoData,this.onPromoAssetLoaded,onPromoClickedCallback);
               promoDynamicWindow.visible = false;
               this.m_externalPromoWindow[loadIndex] = promoDynamicWindow;
               loaderMc = m_element.loader_mc as MovieClip;
               loaderMc.addChild(promoDynamicWindow);
            }
         }
      }
      
      private function onPromoAssetLoaded(dynamicAsset:MovieClip) : void
      {
         if(dynamicAsset != null && m_element != null)
         {
            if(this.m_data_index == this.m_current_load_index)
            {
               this.handlePromoView();
            }
            ++this.m_current_load_index;
            this.createNextPromoDynamicWindow();
         }
      }
      
      override public function release() : void
      {
         this.m_externalPromoWindow = null;
         super.release();
      }
      
      public function rotatePromos(updateView:Boolean = true) : void
      {
         var original_index:int = this.m_data_index;
         ++this.m_data_index;
         this.m_data_index = Boolean(this.m_externalPromoWindow) && this.m_data_index < this.m_externalPromoWindow.length ? this.m_data_index : 0;
         if(this.m_data_index != original_index)
         {
            if(Boolean(updateView) && Boolean(this.m_externalPromoWindow) && Boolean(this.m_externalPromoWindow[this.m_data_index]))
            {
               if(this.m_externalPromoWindow[original_index])
               {
                  this.m_externalPromoWindow[original_index].visible = false;
               }
               this.handlePromoView();
            }
         }
      }
      
      public function switchToPromoIndex(promoIndex:int) : void
      {
         if(Boolean(this.m_data_index != promoIndex) && Boolean(this.m_data) && promoIndex < this.m_data.length)
         {
            if(this.m_externalPromoWindow[promoIndex] != null)
            {
               this.m_externalPromoWindow[this.m_data_index].visible = false;
               this.m_data_index = promoIndex;
               this.handlePromoView();
            }
            else
            {
               this.m_data_index = promoIndex;
            }
         }
      }
      
      private function handlePromoView() : void
      {
         var starterPackPromoName:String = null;
         this.m_externalPromoWindow[this.m_data_index].visible = true;
         if(this.m_data[this.m_data_index])
         {
            starterPackPromoName = Global.flashHotParams[StarterPackUtility.STARTER_PACK_PROMO_FLAG];
            if(starterPackPromoName != "" && this.m_data[this.m_data_index].name == starterPackPromoName)
            {
               MarketStatsManager.countStarterPackMarketStat(StarterPackUtility.STARTER_PACK_MARKET_AD_KINGDOM,StarterPackUtility.STARTER_PACK_MARKET_VIEW_PHYLUM);
            }
            else if(this.m_data[this.m_data_index].size != "Carnival")
            {
               MarketStatsManager.countViewPromos(this.m_data[this.m_data_index].name);
            }
         }
      }
   }
}

