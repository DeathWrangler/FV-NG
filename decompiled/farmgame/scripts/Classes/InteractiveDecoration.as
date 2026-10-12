package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Managers.FarmGameSettingsManager;
   import Transactions.TClear;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.media.SoundTransform;
   import flash.net.*;
   
   public class InteractiveDecoration extends Decoration
   {
      
      public static const ACTIVATE_OBJECT:String = "activate";
      
      public static const GOTOURL_OBJECT:String = "gotourl";
      
      private static const DONT_FIRE:Number = Number.MAX_VALUE;
      
      private static const FIRE_NOW:Number = 0;
      
      private var m_activeFrame:int = -1;
      
      private var m_minWait:int = 45;
      
      private var m_maxWait:int = 90;
      
      private var m_nextFire:Number = 1.7976931348623157e+308;
      
      private var m_hasUserActivated:Boolean = false;
      
      protected var m_expendable:Boolean = false;
      
      protected const SWF_FRAME_TOLERANCE:int = 3;
      
      public function InteractiveDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function onItemImageLoaded(event:Event) : void
      {
         super.onItemImageLoaded(event);
         this.initializeActionTimer();
      }
      
      override protected function onImageLoaded(event:Event) : void
      {
         super.onImageLoaded(event);
         if(this.m_activeFrame == -1)
         {
            this.initializeActionTimer();
         }
      }
      
      override public function attach() : void
      {
         super.attach();
         this.initializeActionTimer();
      }
      
      protected function initializeActionTimer() : void
      {
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("activeFrame"))
            {
               this.m_activeFrame = m_item.getIntFromDataSource("activeFrame");
               this.m_activeFrame = Math.max(this.m_activeFrame,1);
               this.m_minWait = m_item.getIntFromDataSource("minWait");
               this.m_maxWait = m_item.getIntFromDataSource("maxWait");
               this.m_maxWait = Math.max(this.m_minWait,this.m_maxWait);
               this.m_expendable = m_item.getBoolFromDataSource("expendable");
               if(this.m_nextFire == DONT_FIRE && !this.m_expendable)
               {
                  this.m_nextFire = this.getNextFireTime();
               }
            }
         }
         else if(Boolean(m_item.xml.activeFrame) && m_item.xml.activeFrame != "")
         {
            this.m_activeFrame = m_item.xml.activeFrame;
            this.m_activeFrame = Math.max(this.m_activeFrame,1);
            this.m_minWait = m_item.xml.minWait;
            this.m_maxWait = m_item.xml.maxWait;
            this.m_maxWait = Math.max(this.m_minWait,this.m_maxWait);
            if(Boolean(m_item.xml.@expendable) && m_item.xml.@expendable.toString() == "true")
            {
               this.m_expendable = true;
            }
            if(this.m_nextFire == DONT_FIRE && !this.m_expendable)
            {
               this.m_nextFire = this.getNextFireTime();
            }
         }
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(GlobalEngine.currentTime >= this.m_nextFire)
         {
            if(m_content is MovieClip)
            {
               if(this.m_activeFrame >= MovieClip(m_content).currentFrame && this.m_activeFrame - MovieClip(m_content).currentFrame < this.SWF_FRAME_TOLERANCE)
               {
                  this.activate();
               }
               else if(this.m_expendable && MovieClip(m_content).totalFrames - MovieClip(m_content).currentFrame < this.SWF_FRAME_TOLERANCE)
               {
                  this.m_nextFire = DONT_FIRE;
                  this.deleteExpendableObject();
               }
            }
         }
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return !(this.m_expendable && this.m_hasUserActivated);
      }
      
      override protected function getMenuItems() : Array
      {
         var parentMenuItems:Array = null;
         var menuItem:Object = null;
         var hasMoreInfoURL:Boolean = false;
         var itemName:String = m_item.name;
         var menuArray:Array = [];
         if(!(this.m_expendable && this.m_hasUserActivated))
         {
            if(this.m_activeFrame > 1)
            {
               menuArray.push({
                  "label":ZLocUtils.t("FarmGame",itemName + "_Activate"),
                  "action":ACTIVATE_OBJECT
               });
            }
            parentMenuItems = super.getMenuItems();
            for each(menuItem in parentMenuItems)
            {
               menuArray.push(menuItem);
            }
            hasMoreInfoURL = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasMoreInfoURL = m_item.hasPropertyInDataSource("moreInfoURL");
            }
            else
            {
               hasMoreInfoURL = Boolean(m_item.xml.moreInfoURL) && m_item.xml.moreInfoURL.toString() != "";
            }
            if(hasMoreInfoURL)
            {
               menuArray.push({
                  "label":ZLocUtils.t("FarmGame",itemName + "_MoreInfo"),
                  "action":GOTOURL_OBJECT
               });
            }
         }
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case ACTIVATE_OBJECT:
                  this.m_hasUserActivated = true;
                  this.activate();
                  break;
               default:
                  super.onMenuClick(event);
                  break;
               case GOTOURL_OBJECT:
                  this.gotoURL();
            }
         }
      }
      
      public function activate() : void
      {
         var st:SoundTransform = null;
         if(this.m_activeFrame > 0)
         {
            if(m_content is MovieClip)
            {
               st = new SoundTransform();
               if(Global.player.isSfxDisabled())
               {
                  st.volume = 0;
               }
               else
               {
                  st.volume = 1;
               }
               MovieClip(m_content).soundTransform = st;
               MovieClip(m_content).gotoAndPlay(this.m_activeFrame);
               if(this.m_expendable)
               {
                  this.m_nextFire = FIRE_NOW;
               }
               else
               {
                  this.m_nextFire = this.getNextFireTime();
               }
            }
         }
      }
      
      private function getNextFireTime() : Number
      {
         var wait:int = Math.random() * (this.m_maxWait - this.m_minWait) + this.m_minWait;
         return GlobalEngine.currentTime + wait * 1000;
      }
      
      protected function deleteExpendableObject() : void
      {
         this.detach();
         addTransaction(new TClear(this));
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         if(!(m_content is MovieClip) || !(newContent is Bitmap))
         {
            super.replaceContent(newContent,shouldRedrawMask);
         }
      }
      
      protected function gotoURL() : void
      {
         var url:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("moreInfoURL"))
            {
               url = m_item.getStringFromDataSource("moreInfoURL");
            }
         }
         else if(Boolean(m_item.xml.moreInfoURL) && m_item.xml.moreInfoURL.toString() != "")
         {
            url = m_item.xml.moreInfoURL.toString() as String;
         }
         if(url != "" && url.indexOf("") >= 0)
         {
            url = url.replace("{*sn_app_url*}",GlobalEngine.getFlashVar("sn_app_url"));
            navigateToURL(new URLRequest(url),"_blank");
         }
      }
      
      override public function stop() : void
      {
         super.pause();
      }
   }
}

