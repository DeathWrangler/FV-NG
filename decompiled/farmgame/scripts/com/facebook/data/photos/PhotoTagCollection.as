package com.facebook.data.photos
{
   import com.facebook.utils.FacebookArrayCollection;
   
   [Bindable]
   public class PhotoTagCollection extends FacebookArrayCollection
   {
      
      public function PhotoTagCollection(param1:Array = null)
      {
         super(param1,TagData);
      }
      
      public function addPhotoTag(param1:TagData) : void
      {
         this.addItem(param1);
      }
   }
}

