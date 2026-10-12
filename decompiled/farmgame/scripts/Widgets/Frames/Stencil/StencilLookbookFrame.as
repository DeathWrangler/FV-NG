package Widgets.Frames.Stencil
{
   import Engine.Managers.StatsManager;
   import Managers.StencilManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class StencilLookbookFrame extends FarmSlotContainerFrame
   {
      
      protected const FIRST_PAGE:uint = 0;
      
      protected const CAROUSEL_TIMER:int = 5;
      
      private var m_isCarouselPlaying:Boolean = true;
      
      private var m_playBtn:FarmButton;
      
      private var m_pauseBtn:FarmButton;
      
      private var image:FarmIcon;
      
      private var m_timer:Timer;
      
      public function StencilLookbookFrame(element:MovieClip)
      {
         super(element);
         addWidget(new FarmButton(m_element.leftArrow_bt,this.onPageBackward));
         addWidget(new FarmButton(m_element.rightArrow_bt,this.onPageForward));
         addWidget(this.m_playBtn = new FarmButton(m_element.play_bt,this.toggleControlBtn));
         addWidget(this.m_pauseBtn = new FarmButton(m_element.pause_bt,this.toggleControlBtn));
         addWidget(this.image = new FarmIcon(m_element.image_mc));
         addWidget(m_currentPageLabel = new ZwTextField(m_element.page_tf));
         m_pagingComponent.maxPageNumber = this.manager.lookbookImages.length - 1;
         m_pagingComponent.currentPageNumber = this.FIRST_PAGE;
         this.startCarousel();
         this.updateControlState();
      }
      
      private function get manager() : StencilManager
      {
         return StencilManager.instance();
      }
      
      override public function release() : void
      {
         super.release();
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         this.image = null;
      }
      
      override public function refresh() : void
      {
         this.image.loadIcon(this.manager.lookbookImages[m_pagingComponent.currentPageNumber]);
         this.image.setIconHeight(m_element.image_mc.height);
         this.image.setIconWidth(m_element.image_mc.width);
         this.redrawCurrentPageLabel();
      }
      
      override protected function redrawCurrentPageLabel() : void
      {
         if(m_currentPageLabel)
         {
            if(m_pagingComponent.maxPageNumber)
            {
               m_currentPageLabel.text = (m_pagingComponent.currentPageNumber + 1).toString() + "/" + (m_pagingComponent.maxPageNumber + 1).toString();
            }
            else
            {
               m_currentPageLabel.text = "";
            }
         }
      }
      
      private function getImageName(imageName:String) : String
      {
         var _imageName:String = imageName.split("/")[3];
         return _imageName.split(".")[0];
      }
      
      private function updateControlState() : void
      {
         if(this.m_isCarouselPlaying)
         {
            this.m_playBtn.visible = false;
            this.m_pauseBtn.visible = true;
            this.startCarousel();
         }
         else
         {
            this.m_playBtn.visible = true;
            this.m_pauseBtn.visible = false;
            this.pauseCarousel();
            StatsManager.count(this.manager.featureName,"lookbook_pause",this.getImageName(this.manager.lookbookImages[m_pagingComponent.currentPageNumber]));
         }
      }
      
      private function startCarousel() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(this.CAROUSEL_TIMER * 1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
         else
         {
            this.m_timer.reset();
            this.m_timer.start();
         }
      }
      
      private function pauseCarousel() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.stop();
         }
      }
      
      private function toggleControlBtn(e:Event) : void
      {
         this.m_isCarouselPlaying = !this.m_isCarouselPlaying;
         this.updateControlState();
      }
      
      private function onPageForward(e:Event) : void
      {
         if(m_pagingComponent.isOnLastPage())
         {
            m_pagingComponent.currentPageNumber = this.FIRST_PAGE;
         }
         else
         {
            m_pagingComponent.onPageForward(e);
         }
      }
      
      private function onPageBackward(e:Event) : void
      {
         if(m_pagingComponent.isOnFirstPage())
         {
            m_pagingComponent.currentPageNumber = m_pagingComponent.maxPageNumber;
         }
         else
         {
            m_pagingComponent.onPageBack(e);
         }
      }
      
      private function onTimer(e:Event) : void
      {
         this.onPageForward(e);
      }
   }
}

