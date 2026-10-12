package com.facebook.data.pages
{
   import com.facebook.data.FacebookLocation;
   import flash.events.EventDispatcher;
   
   [Bindable]
   public class PageInfoData extends EventDispatcher
   {
      
      public var starring:String;
      
      public var genre:String;
      
      public var season:String;
      
      public var bio:String;
      
      public var name:String;
      
      public var record_label:String;
      
      public var band_members:String;
      
      public var pic_small:String;
      
      public var schedule:String;
      
      public var website:String;
      
      public var influences:String;
      
      public var founded:String;
      
      public var hours:String;
      
      public var directed_by:String;
      
      public var location:FacebookLocation;
      
      public var mission:String;
      
      public var type:String;
      
      public var awards:String;
      
      public var pic_large:String;
      
      public var pic_big:String;
      
      public var network:String;
      
      public var page_id:Number;
      
      public var studio:String;
      
      public var release_date:String;
      
      public var products:String;
      
      public var hometown:String;
      
      public var produced_by:String;
      
      public var pic_square:String;
      
      public var company_overview:String;
      
      public var plot_outline:String;
      
      public var has_added_app:Boolean;
      
      public var written_by:String;
      
      public function PageInfoData()
      {
         super();
      }
   }
}

