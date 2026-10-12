package Widgets.Windows
{
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimalSanctuaryV2TravelFarmWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_title_tf:ZwTextField;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_travelBt:FarmAnimatedTextButton;
      
      private var m_viralBt:FarmAnimatedTextButton;
      
      private var m_allCurrencyAarray:Array = [];
      
      public function AnimalSanctuaryV2TravelFarmWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var m_allCurrencyInfoMc:MovieClip = null;
         var index:int = 0;
         var allCurrencydata:Array = null;
         var currencyIterator:int = 0;
         var currencyMc:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_title_tf = new ZwTextField(m_window[this.TITLE_TF],"");
         }
         if(m_window.hasOwnProperty("travel_overlay_mc"))
         {
            addWidget(this.m_travelBt = new FarmAnimatedTextButton(m_window["travel_overlay_mc"]["travel_okay_bt"],"Travel",this.onTravelWorld));
         }
         if(m_window.hasOwnProperty("viral_task_mc"))
         {
            addWidget(this.m_viralBt = new FarmAnimatedTextButton(m_window["viral_task_mc"]["okay_bt"],"Ask",this.onTravelWorld));
         }
         if(m_window.hasOwnProperty("all_currency_info_mc"))
         {
            m_allCurrencyInfoMc = m_window["all_currency_info_mc"] as MovieClip;
            m_allCurrencyInfoMc.visible = true;
            for(index = 0; index < 3; index++)
            {
               if(m_allCurrencyInfoMc.hasOwnProperty("currency_" + index + "_info_mc"))
               {
                  allCurrencydata = new Array();
                  currencyIterator = 0;
                  currencyMc = m_allCurrencyInfoMc["currency_" + index + "_info_mc"] as MovieClip;
                  if(currencyMc.hasOwnProperty("currency_count_tf"))
                  {
                     allCurrencydata[currencyIterator] = new ZwTextField(currencyMc["currency_count_tf"],"64");
                     currencyIterator++;
                  }
                  if(currencyMc.hasOwnProperty("currency_name_tf"))
                  {
                     allCurrencydata[currencyIterator] = new ZwTextField(currencyMc["currency_name_tf"],this.manager.VAL_COUPON_NAME_TYPE[index]);
                     currencyIterator++;
                  }
                  if(currencyMc.hasOwnProperty("currency_icon_mc"))
                  {
                     allCurrencydata[currencyIterator] = new FarmIcon(currencyMc["currency_icon_mc"]);
                     currencyIterator++;
                  }
                  this.m_allCurrencyAarray[index] = allCurrencydata;
               }
            }
            this.refreshCouponsCount();
         }
      }
      
      public function onTravelWorld(event:Event) : void
      {
         this.manager.onTravelButtonClick();
         super.close();
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
      }
      
      public function refreshCouponsCount() : void
      {
         for(var i:int = 0; i < 3; i++)
         {
            if(Boolean(this.m_allCurrencyAarray) && Boolean(this.m_allCurrencyAarray[i]))
            {
               this.m_allCurrencyAarray[i][0].text = "x" + this.manager.consumableCount(i).toString();
            }
         }
      }
   }
}

